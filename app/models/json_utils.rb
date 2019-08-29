require "./app/models/model_utils.rb"
class JsonUtils
  @@mock_request = false

  def self.mock_request_on()
    @@mock_request = true
  end

  def self.http_get(url, verbose = false)
    if verbose
      Rails.logger.error("HTTP GET: #{url}")
    end
    ok = nil
    data = nil
    if @@mock_request
      ok, data = ModelUtils::mock_get_body(url)
    else
      ok, data = ModelUtils::http_get_body(url)
    end

    if !ok
      Rails.logger.error("Error fetching: #{url}")
      return nil
    end
    return safe_parse(data)
  end

  def self.http_post(url, payload, verbose = false)
    if verbose
      Rails.logger.error("HTTP POST: #{url}")
    end
    ok, data = ModelUtils::http_post(url, payload, "text/json")
    if !ok
      Rails.logger.error("Error posting to: #{url}\r\n#{payload}")
      return nil
    end
    return safe_parse(data)
  end

  def self.safe_parse(json_str)
    if json_str == nil
      Rails.logger.error("Cannot parse nil value as JSON")
      return nil
    end
    JSON.parse(json_str)
  rescue => ex
    Rails.logger.error("Error #{ex.message} parsing #{json_str[0..500]}")
    nil
  end
end
