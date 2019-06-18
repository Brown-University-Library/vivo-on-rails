class ModelUtils

  def self.vivo_id(id)
    return "" if id == nil
    id.split("/").last
  end

  def self.type_for_id(id)
    solr_url = ENV["SOLR_URL"]
    logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil
    solr = SolrLite::Solr.new(solr_url, logger)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
    if solr_doc != nil
      return (solr_doc["record_type"] || []).first
    end

    # Special logic for team since they are not stored in Solr at this point.
    if Team.find_by_id(id) != nil
      return "TEAM"
    end

    nil
  end

  # Generates the proper URL for a given file path in VIVO.
  # For example for file_path
  #     "/file/n12345/somebody.jpg"
  # it returns
  #     "/profile-images/123/45/somebody.jpg"
  def self.thumbnail_url(file_path, root_url = nil)
    if (file_path || "").strip.length == 0
      return nil
    end
    if file_path[0] != "/"
      return nil # Must start with a /
    end
    tokens = file_path.split("/")
    if tokens.count != 4
      return nil
    end
    file_name = safe_thumbnail_file(tokens[3])
    id = tokens[2]
    case
    when id.length >= 3 && id.length <= 4
      part_a = id[1..-1]
      url = "#{root_url}/profile-images/#{part_a}/#{file_name}"
    when id.length >= 5 && id.length <= 7
      part_a = id[1..3]
      part_b = id[4..-1]
      url = "#{root_url}/profile-images/#{part_a}/#{part_b}/#{file_name}"
    when id.length >= 8 && id.length <= 9
      part_a = id[1..3]
      part_b = id[4..6]
      part_c = id[7..-1]
      url = "#{root_url}/profile-images/#{part_a}/#{part_b}/#{part_c}/#{file_name}"
    when id.length == 33
      # It's a UUID.
      # UUIDs come in the form: "n12345678901234567890123456789012"
      #
      # Drop the "n" and break the rest of the string into subpaths
      # (3 characters each, except the last one which would be 2 characters long).
      # For example, UUID "n649cb8816f214915b8d659c3fee9ffa9" will be brokend
      # down as: "649/cb8/816/f21/491/5b8/d65/9c3/fee/9ff/a9/"
      #
      url = "#{root_url}/profile-images/"
      (0..10).each do |i|
        a = (i*3) + 1
        b = a + 2
        url += id[a..b] + "/"
      end
      url += "#{file_name}"
    else
      url = nil
    end
    url
  end

  def self.safe_thumbnail_file(filename)
    return nil if filename == nil
    filename.gsub("+", "^20")
  end

  def self.set_values_from_hash(obj, hash)
    return if hash == nil
    hash.each do |key, value|
      setter = key.to_s + "="
      if obj.respond_to?(setter)
        if value.class == Array
          getter = key.to_s
          if obj.send(getter).class == Array
            obj.send(setter, value)
          else
            # If we got an array but we were not expecting one
            # just get the first value (this is useful when
            # handling values from Solr)
            obj.send(setter, value.first)
          end
        else
          obj.send(setter, value)
        end
      end
    end
  end

  def self.http_get_body(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 10
    http.ssl_timeout = 10
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    ok = (response.code >= "200" && response.code <= "299")
    [ok, response.body]
  rescue => ex
    Rails.logger.error("Fetching: #{url}. Exception: #{ex}")
    [false, ""]
  end
end
