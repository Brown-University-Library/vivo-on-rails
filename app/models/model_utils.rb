class ModelUtils
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
end
