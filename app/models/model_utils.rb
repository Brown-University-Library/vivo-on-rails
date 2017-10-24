class ModelUtils
  def self.safe_thumbnail(value)
    if (value || "").strip.length == 0
      return nil
    end
    if value.start_with?("http://vivo.brown.edu")
      # Prefer HTTPS
      return value.gsub("http://", "https://")
    end
    value
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
    id = tokens[2]
    if id.length != 6
      return nil
    end
    part_a = id[1..3]
    part_b = id[4..5]
    file_name = tokens[3]
    url = "#{root_url}/profile-images/#{part_a}/#{part_b}/#{file_name}"
    url
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
end
