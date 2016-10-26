module ModelUtils
  def set_values_from_hash(hash)
    return if hash == nil
    hash.each do |key, value|
      setter = key.to_s + "="
      if self.respond_to?(setter)
        if value.class == Array
          getter = key.to_s
          if self.send(getter).class == Array
            self.send(setter, value)
          else
            # If we got an array but we were not expecting one
            # just get the first value (this is useful when
            # handling values from Solr)
            self.send(setter, value.first)
          end
        else
          self.send(setter, value)
        end
      end
    end
  end
end
