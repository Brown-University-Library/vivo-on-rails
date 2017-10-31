class IndividualController < ApplicationController
  APPLICATION_JSON = "application/json"
  APPLICATION_RDF_XML = "application/rdf+xml"
  TEXT_TURTLE = "text/turtle"
  SEE_OTHER = 303

  # This method mimics the `/individual/:id` endpoint in VIVO in that it
  # just redirects the user to the appropriate URL for the given ID. In
  # some instances it redirects to the HTML representation for the ID while
  # in others to the JSON/TURTLE representation.
  def redirect
    id = params["id"]
    content_type = request.headers.env["HTTP_ACCEPT"]
    if content_type == APPLICATION_JSON
      url = individual_export_url(id: id, format: "jsonld")
    elsif content_type == TEXT_TURTLE
      url = individual_export_url(id: id, format: "ttl")
    elsif content_type == APPLICATION_RDF_XML
      url = individual_export_url(id: id, format: "rdf")
    else
      # default to the HTML representation
      url = display_show_url(id)
    end
    redirect_to url, status: SEE_OTHER
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not redirect to record #{id}. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  # This method mimics the `/individual/:id/:id.format` endpoint in VIVO but
  # unlike the `show()` method that redirects the user, this method acts as
  # proxy to VIVO. This method fetches the data directly from VIVO and renders
  # it.
  def export
    id = params["id"]
    format = params["format"]
    case
      when format == "jsonld"
        render_vitro_data(id, APPLICATION_JSON)
      when format == "ttl"
        render_vitro_data(id, TEXT_TURTLE)
      when format == "rdf"
        render_vitro_data(id, APPLICATION_RDF_XML)
      else
        Rails.logger.warn("Invalid format (#{format}) requested.")
        render "error", status: 400
    end
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not fetch record #{id} from VIVO. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  private
    def render_vitro_data(id, content_type)
      vivo_url = ENV["VIVO_BACKEND_URL"]
      vitro = VitroAPI.new(vivo_url)
      data = vitro.get_one(id, content_type)
      render body: data[:body], status: data[:code], content_type: data[:content_type]
    end
end
