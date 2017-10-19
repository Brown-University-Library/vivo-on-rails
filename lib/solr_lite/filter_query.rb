module SolrLite
  # Represents an "fq" in Solr. Field is the field to filter by
  # and value the value to filter by. In a Solr query are represented
  # as "fq=field:value"
  class FilterQuery
    attr_accessor :field, :value, :solr_value, :qs_value, :form_value
    attr_accessor :title, :remove_url

    def initialize(field, value)
      if value.is_a?(String)
        init_single_value(field, value)
      else
        init_multi_value(field, value)
      end
    end

    def init_single_value(field, value)
      @field = field
      @value = value
      # Very important to escape the : otherwise URL.parse throws an error in Linux
      @solr_value = CGI.escape(field + ':"' + value + '"')  # as needed by Solr
      @qs_value = "#{field}|#{CGI.escape(value)}"           # URL friendly (no : or quotes)
      @form_value = "#{field}|#{value}"                     # HTML Form friendly (no encoding, the form auto-encodes on POST)
      @title = field                                        # default to field name
      @remove_url = nil
    end

    # TODO: refactor this code
    def init_multi_value(field, values)
      @field = field
      @value = values.join("^")

      str = ""
      values.each_with_index do |v, i|
        str += '(' + field + ':"' + v + '")'
        lastOne = (i == (values.length-1))
        if !lastOne
          str += " OR "
        end
      end
      # Very important to escape the : otherwise URL.parse throws an error in Linux
      @solr_value = CGI.escape(str)  # as needed by Solr

      str = ""
      values.each_with_index do |v, i|
        str += v
        lastOne = (i == (values.length-1))
        if !lastOne
          str += "^"
        end
      end
      @qs_value = "#{field}|#{CGI.escape(str)}"           # URL friendly (no : or quotes)
      @form_value = "#{field}|#{str}"                     # HTML Form friendly (no encoding, the form auto-encodes on POST)
      @title = field                                        # default to field name
      @remove_url = nil
    end


    # qs is assumed to be value taken from the query string
    # in the form `field|value`. Sometimes the string comes
    # URL encoded, for example:
    #     `field|hello`
    #     `field|hello%20world`
    # CGI.unespace handles these cases nicer than URL.decode
    def self.from_query_string(qs)
      tokens = CGI.unescape(qs).split("|")
      return nil if tokens.count != 2
      field = tokens[0]
      value = tokens[1]
      FilterQuery.new(field, value)
    end
  end
end
