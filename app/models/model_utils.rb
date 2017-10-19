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
