class IndividualController < ApplicationController
  APPLICATION_JSON = "application/json"
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
      url = "/individual/#{id}/#{id}.jsonld"
    elsif content_type == TEXT_TURTLE
      url = "/individual/#{id}/#{id}.ttl"
    else
      # default to the HTML representation
      url = display_show_url(id)
    end
    redirect_to url, status: SEE_OTHER
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
      else
        Rails.logger.warn("Invalid format (#{format}) requested.")
        render "error", status: 400
    end
  end

  private
    def render_vitro_data(id, content_type)
      vivo_url = ENV["VIVO_BACKEND_URL"]
      vitro = VitroAPI.new(vivo_url)
      data = vitro.get_one(id, content_type)
      render body: data[:body], status: data[:code], content_type: data[:content_type]
    end
end
