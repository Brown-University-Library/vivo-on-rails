# Interface's with VIVO/Vitro native API
# We use this to provide raw VIVO data in our front end without having
# to re-implement what VIVO does natively. For example we use this to
# to provide JSON-LD representations of faculty data.
#
class VitroAPI
  APPLICATION_JSON = "application/json"
  APPLICATION_RDF_XML = "application/rdf+xml"
  TEXT_TURTLE = "text/turtle"
  VIVO_TIMEOUT = 5  # seconds

  def initialize(vivo_url)
    @vivo_url = vivo_url
  end

  def get_one(id, content_type = APPLICATION_JSON)
    case
      when content_type == APPLICATION_JSON
        url = "#{@vivo_url}/individual/#{id}/#{id}.jsonld"
      when content_type == TEXT_TURTLE
        url = "#{@vivo_url}/individual/#{id}/#{id}.ttl"
      when content_type == APPLICATION_RDF_XML
        url = "#{@vivo_url}/individual/#{id}/#{id}.rdf"
      else
        return nil
    end
    response = http_get(url, content_type)
    if response.code != "200"
      err_msg = "Error fetching data for ID: #{id}, content type: #{content_type} from VIVO."
      Rails.logger.warn(err_msg)
    end
    return {body: response.body, code: response.code, content_type: content_type}
  end

  def get_one_jsonld(id)
    return get_one(id, APPLICATION_JSON)
  end

  def get_one_turtle(id)
    return get_one(id, TEXT_TURTLE)
  end

  private
    def http_get(url, content_type)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if url.start_with?("https://")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http.open_timeout = VIVO_TIMEOUT
      http.read_timeout = VIVO_TIMEOUT
      request = Net::HTTP::Get.new(uri.request_uri)
      if content_type
        request["Content-Type"] = content_type
      end
      response = http.request(request)
    end
end
