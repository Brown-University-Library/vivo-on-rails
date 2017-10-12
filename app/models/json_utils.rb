class JsonUtils
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
