require "./lib/solr_lite/solr.rb"
class IndividualController < ApplicationController
  APPLICATION_JSON = "application/json"
  TEXT_TURTLE = "text/turtle"
  SEE_OTHER = 303

  # This method replaces the original `/individual:id` endpoint in VIVO.
  # In this version we redirect the user to the more specific URL
  # (/faculty/:id or /organization/:id).
  #
  # Long teram I am not sure whether I want to do what VIVO does
  # (everbody is under /individual/) or use specific URLs for faculty
  # vs organizations. 
  def display
    id = params["id"]
    if id == nil
      render body: "No individual requested", status: 404
    else
      type = get_type_for_id(id)
      if type == "PEOPLE"
        url = faculty_show_url(id)
        redirect_to url, status: SEE_OTHER
      elsif type == "ORGANIZATION"
        url = organization_show_url(id)
        redirect_to url, status: SEE_OTHER
      else
        if type == nil
          err_msg = "Individual ID #{id} was not found"
          Rails.logger.warn(err_msg)
          render body: err_msg, status: 404
        else
          # Render the JSON-LD representation in case somebody relies on the
          # original `/display/id` URL for other VIVO types that are neither
          # PEOPLE nor ORGANIZATION.
          Rails.logger.warn("ID #{id} is of type #{type}, returning JSON-LD representation")
          render_raw_data_from_vivo(id, APPLICATION_JSON)
        end
      end
    end
  end

  # This method mimics the `/individual/:id` endpoint in VIVO in that it
  # just redirects the user to the appropriate URL for the given ID. In
  # some instances it redirects to the HTML representation for the ID while
  # in others to the JSON/TURTLE representation.
  def redirect
    id = params["id"]
    if id == nil
      render body: "No individual requested", status: 404
    else
      content_type = request.headers.env["HTTP_ACCEPT"]
      if content_type == APPLICATION_JSON
        url = "/individual/#{id}/#{id}.jsonld"
      elsif content_type == TEXT_TURTLE
        url = "/individual/#{id}/#{id}.ttl"
      else
        # default to the HTML representation
        url = faculty_show_url(id)
      end
      redirect_to url, status: SEE_OTHER
    end
  end

  # This method mimics the `/individual/:id/:id.ext` endpoint in VIVO but
  # unlike the show() that redirects the user, this method acts as proxy
  # to VIVO. This method fetches the data directly from VIVO and renders it.
  def export
    id = params["id"]
    if id == nil
      render body: "No individual requested", status: 404
    else
      format = params["format"]
      case
        when format == "jsonld"
          render_raw_data_from_vivo(id, APPLICATION_JSON)
        when format == "ttl"
          render_raw_data_from_vivo(id, TEXT_TURTLE)
        else
          render_raw_data_from_vivo(id, "unknown")
      end
    end
  end

  private
    def render_raw_data_from_vivo(id, content_type)
      vivo_url = ENV["VIVO_BACKEND_URL"]
      case
        when content_type == APPLICATION_JSON
          url = "#{vivo_url}/individual/#{id}/#{id}.jsonld"
        when content_type == TEXT_TURTLE
          url = "#{vivo_url}/individual/#{id}/#{id}.ttl"
        else
          url = nil
      end
      if url
        response = http_get(url, content_type)
        if response.code == "200"
          render body: response.body, content_type: content_type
        else
          err_msg = "Error fetching data for ID: #{id}, content type: #{content_type} from VIVO."
          Rails.logger.warn(err_msg)
          render body: err_msg, status: response.code # Use VIVO's original response code
        end
      else
        render body: "Invalid content type (#{content-type}) requested", status: 400
      end
    end

    def http_get(url, content_type)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if url.start_with?("https://")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new(uri.request_uri)
      if content_type
        request["Content-Type"] = content_type
      end
      response = http.request(request)
    end

    def get_type_for_id(id)
      solr_url = ENV["SOLR_URL"]
      solr = SolrLite::Solr.new(solr_url)
      solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
      return nil if solr_doc == nil
      (solr_doc["record_type"] || []).first
    end
end
