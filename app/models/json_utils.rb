require "./app/models/model_utils.rb"
class JsonUtils

  def self.http_get(url)
    ok, data = ModelUtils::http_get_body(url)
    if !ok
      Rails.logger.error("Error fetching: #{url}")
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
