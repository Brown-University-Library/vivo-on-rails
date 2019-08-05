require "./app/models/model_utils.rb"
require "./app/models/faculty_export.rb"

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
    type = ModelUtils.type_for_id(id)
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

  def edit
    if ENV["NEW_EDITOR"] != "true"
      raise "Edit not allowed"
    end

    id = params["id"]
    type = ModelUtils.type_for_id(id)
    if type != "PEOPLE"
      raise "Cannot edit record type #{type}."
    end
    edit_faculty(id)
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not edit record #{id}. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  private
    def edit_faculty(id)
      id = params[:id]
      faculty = Faculty.load_from_solr(id)
      if faculty == nil
        Rails.logger.error("Could not render faculty #{id}.")
        render "error", status: 500
        return
      end

      force_show_viz = params[:viz] == "true"
      faculty.load_edit_data()
      referer = search_url()

      @presenter = FacultyPresenter.new(faculty.item, search_url(), referer, force_show_viz)
      @presenter.user = current_user
      @presenter.edit_mode = true
      @presenter.edit_errors = faculty.errors
      @presenter.edit_allowed = faculty.errors.count == 0 && current_user.can_edit?(id)
      render "faculty/show"
    end

    def render_faculty(id)
      id = params[:id]
      faculty = Faculty.load_from_solr(id)
      if faculty == nil
        Rails.logger.error("Could not render faculty #{id}.")
        render "error", status: 500
        return
      end

      if params["format"] != nil
        case params["format"]
        when "csv"
          export = FacultyExport.new([faculty])
          send_data export.to_csv(), :type => "application/xml", :filename=>"#{id}.csv", :disposition => 'attachment'
        when "xml"
          export = FacultyExport.new([faculty])
          send_data export.to_excel(), :type => "application/xml", :filename=>"#{id}.xml", :disposition => 'attachment'
        when "json_txt"
          render :json => faculty.json_txt.to_json
        when"json"
          render :json => faculty.item.to_json
        else
          Rails.logger.error("Unknown format #{params['format']} received for faculty #{id}.")
          render "error", status: 500
        end
        return
      end

      force_show_viz = params[:viz] == "true"
      referer = request.headers.env["HTTP_REFERER"]
      @presenter = FacultyPresenter.new(faculty.item, search_url(), referer, force_show_viz)
      @presenter.user = current_user
      @presenter.edit_allowed = current_user.can_edit?(id)
      render "faculty/show"
    end

    def render_org(id)
      organization = Organization.load_from_solr(id)
      if organization == nil
        Rails.logger.error("Could not render organization #{id}.")
        render "error", status: 500
        return
      end

      if params["format"] != nil
        case params["format"]
        when "csv"
          export = FacultyExport.new(organization.faculty_list())
          send_data export.to_csv(), :type => "application/xml", :filename=>"#{id}.csv", :disposition => 'attachment'
        when "xml"
          export = FacultyExport.new(organization.faculty_list())
          send_data export.to_excel(), :type => "application/xml", :filename=>"#{id}.xml", :disposition => 'attachment'
        when "json_txt"
          render :json => organization.json_txt.to_json
        when"json"
          render :json => organization.item.to_json
        else
          Rails.logger.error("Unknown format #{params['format']} received for organization #{id}.")
          render "error", status: 500
        end
        return
      end

      show_viz = ENV["VIZ_ENABLED"] == "true" || params[:viz] == "true"
      referer = request.headers.env["HTTP_REFERER"]
      @presenter = OrganizationPresenter.new(organization.item, search_url(), referer, show_viz)
      @presenter.user = current_user
      render "organization/show"
    end

    def render_not_found(id)
      # Use the page title to track page not found in Google Analytics
      # (see https://www.practicalecommerce.com/Locating-404s-with-Google-Analytics)
      @page_title = "Page not found"
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
