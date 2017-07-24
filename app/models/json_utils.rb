class JsonUtils
  def self.safe_parse(json_str)
    if ENV["USE_VIVO_SOLR"] == "true"
      if !json_str.start_with?("{")
        json_str = "{" + json_str + "}"
      end
      clean_str = JsonUtils.clean_json_string(json_str)
      JSON.parse(clean_str)
    else
      JSON.parse(json_str)
    end
  rescue => ex
    # TODO: Better exception handling
    puts "=============================="
    puts ex
    puts "=============================="
    {}
  end

  def self.clean_json_string(json_str)
    # HACK to handle the poorly formed JSON that is coming from
    # our Solr installation. We should be able to remove this
    # code once we fix the JSON in our Solr installation.
    str = json_str
    str.gsub!("\n", " ")
    str.gsub!("\r", " ")
    str.gsub!("\t", " ")
    str.gsub!(",}", "}")
    clean_str = ""
    in_quotes = false
    i = 0
    prev_c = nil
    next_c = nil
    str.each_char do |c|
      next_c = str[i+1]
      if c == '"'
        if in_quotes == true
          if next_c == ":" || next_c == "]" || next_c == "}"
            in_quotes = false
            clean_str += c
          elsif next_c == "," && (str[i+2] == '"' || str[i+2] == "]")
            in_quotes = false
            clean_str += c
          else
            clean_str += '\"'
          end
        else
          in_quotes = true
          clean_str += c
        end
      else
        clean_str += c
      end
      prev_c = c
      i += 1
    end
    clean_str
  end
end
