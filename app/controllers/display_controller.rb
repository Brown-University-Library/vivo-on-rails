# require "./lib/solr_lite/solr.rb"
class DisplayController < ApplicationController
  def index
    redirect_to search_url()
  end

  # The original VIVO used to serve the profile images directly.
  # This method handles those requests and redirects the client to
  # pick the image from the new location outside of VIVO.
  def old_image
    images_url = ENV["IMAGES_URL"]
    legacy_path = "/file/#{params[:id]}/#{params[:file_name]}.#{params[:format]}"
    new_thumbnail = ModelUtils.thumbnail_url(legacy_path, images_url)
    if new_thumbnail != nil
      Rails.logger.warn("Legacy path redirected: #{legacy_path} => #{new_thumbnail}")
      redirect_to new_thumbnail, :status => :moved_permanently
    else
      Rails.logger.warn("Legacy path could not be redirected: #{legacy_path}")
      render "not_found", status: 404, formats: [:html]
    end
  end

  # This method replaces the original `/display/:id` endpoint in VIVO.
  #
  # Notice that if the client passes an HTTP Header with "Accept: application/json"
  # or "Accept: text/turtle" Rails will try to find an appropriate view for
  # the format requested and blow up because we only support HTML. VIVO ignores
  # the "Accept" header and always return HTML.
  def show
    id = params["id"]
    type = type_for_id(id)
    case type
    when nil
      render_not_found(id)
    when "PEOPLE"
      render_faculty(id)
    when "ORGANIZATION"
      render_org(id)
    else
      # Render the JSON-LD representation in case somebody relies on the
      # original `/display/id` URL for other VIVO types that are neither
      # PEOPLE nor ORGANIZATION.
      render_vitro_data(id, type)
    end
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not render record #{id}, type #{type}. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  def visualizations
    id = params["id"]
    faculty = Faculty.load_from_solr(id)
    @presenter = FacultyPresenter.new(faculty.item, search_url(), nil, false)
    render "faculty/visualizations"
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not render visualizations for #{id}. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  # this should be on its own controller
  def data_coauthor
    id = params["id"]
    faculty = Faculty.load_from_solr(id)
    data_file = "./public/vizdata/#{id}.json"
    if File.file?(data_file)
      data = File.read(data_file)
      render :json => JSON.parse(data)
    else
      render :status => 404, :json => []
    end
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not render visualizations for #{id}. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  private
    def type_for_id(id)
      solr_url = ENV["SOLR_URL"]
      solr = SolrLite::Solr.new(solr_url)
      solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
      return nil if solr_doc == nil
      (solr_doc["record_type"] || []).first
    end

    def render_faculty(id)
      id = params[:id]
      faculty = Faculty.load_from_solr(id)
      if faculty == nil
        Rails.logger.error("Could not render faculty #{id}.")
        render "error", status: 500
        return
      end

      if params["format"] == "json_txt"
        render :json => faculty.json_txt.to_json
        return
      end

      if params["format"] == "json"
        render :json => faculty.item.to_json
        return
      end

      show_viz = false
      referer = request.headers.env["HTTP_REFERER"]
      @presenter = FacultyPresenter.new(faculty.item, search_url(), referer, show_viz)
      render "faculty/show"
    end

    def render_org(id)
      organization = Organization.load_from_solr(id)
      if organization == nil
        Rails.logger.error("Could not render organization #{id}.")
        render "error", status: 500
        return
      end

      if params["format"] == "json_txt"
        render :json => organization.json_txt.to_json
        return
      end

      if params["format"] == "json"
        render :json => organization.item.to_json
        return
      end

      referer = request.headers.env["HTTP_REFERER"]
      @presenter = OrganizationPresenter.new(organization.item, search_url(), referer)
      render "organization/show"
    end

    def render_not_found(id)
      err_msg = "Individual ID (#{id}) was not found"
      Rails.logger.warn(err_msg)
      render "not_found", status: 404, formats: [:html]
    end

    def render_vitro_data(id, type)
      if ENV["LEGACY_DISPLAY_ENABLED"] == "true"
        Rails.logger.warn("ID #{id} is of type #{type}, returning JSON-LD representation")
        vivo_url = ENV["VIVO_BACKEND_URL"]
        vitro = VitroAPI.new(vivo_url)
        data = vitro.get_one(id)
        render body: data[:body], status: data[:code], content_type: data[:content_type]
      else
        Rails.logger.warn("ID #{id} is of type #{type}, legacy display is not enabled (skipping call to VIVO)")
        render "not_found", status: 404, formats: [:html]
      end
    end
end
