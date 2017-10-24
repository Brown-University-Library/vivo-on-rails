require "./lib/solr_lite/solr.rb"
class DisplayController < ApplicationController
  def index
    redirect_to search_url()
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
      from_solr = true
      faculty = Faculty.get_one(id)
      if faculty == nil
        Rails.logger.error("Could not render faculty #{id}.")
        render "error", status: 500
        return
      end

      if params["debug"] == "true"
        render :json => faculty.to_json
        return
      end

      referer = request.headers.env["HTTP_REFERER"]
      @presenter = FacultyPresenter.new(faculty, search_url(), referer)
      render "faculty/show"
    end

    def render_org(id)
      @presenter = DefaultPresenter.new()
      @organization = Organization.get_one(id)
      if @organization == nil
        Rails.logger.error("Could not render organization #{id}.")
        render "error", status: 500
        return
      end
      render "organization/show"
    end

    def render_not_found(id)
      err_msg = "Individual ID (#{id}) was not found"
      Rails.logger.warn(err_msg)
      render "not_found", status: 404
    end

    def render_vitro_data(id, type)
      Rails.logger.warn("ID #{id} is of type #{type}, returning JSON-LD representation")
      vivo_url = ENV["VIVO_BACKEND_URL"]
      vitro = VitroAPI.new(vivo_url)
      data = vitro.get_one(id)
      render body: data[:body], status: data[:code], content_type: data[:content_type]
    end
end
