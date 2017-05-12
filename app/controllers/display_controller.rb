class DisplayController < ApplicationController
  def index
    redirect_to search_url()
  end

  # This method replaces the original `/display/:id` endpoint in VIVO.
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
      from_solr = false if params[:fuseki] == "true"
      faculty = Faculty.get_one(id, from_solr)
      @presenter = FacultyPresenter.new(faculty)
      render "faculty/show"
    end

    def render_org(id)
      @presenter = DefaultPresenter.new()
      @organization = Organization.get_one(id)
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
