module SolrLite
  # Represents an "fq" in Solr. Field is the field to filter by
  # and value the value to filter by. In a Solr query are represented
  # as "fq=field:value"
  class FilterQuery
    attr_reader :field, :value, :solr_value, :qs_value
    attr_accessor :title, :remove_url
    def initialize(field, value)
      @field = field
      @value = value
      @solr_value = "#{field}:\"#{value}\""   # as needed by Solr
      @qs_value = "#{field}|#{value}"         # URL friendly (no : or quotes)
      @title = field                          # default to field name
      @remove_url = nil
      # TODO: Add property for add_url
    end

    # qs is assumed to be value taken from the query string
    # in the form `field:"value"`. Sometimes the string comes
    # URL encoded, for example:
    #     `field%3A"value"`
    #     `field%3A"value%2C+whatever`
    # CGI.unespace handles these cases nicer than URL.decode
    def self.from_query_string(qs)
      tokens = CGI.unescape(qs).split("|")
      return nil if tokens.count != 2
      field = tokens[0]
      value = tokens[1]
      FilterQuery.new(field, value)
    end

    private
      def self.strip_quotes(value)
        if value.start_with?('"') && value.end_with?('"')
          value[1..-2]
        else
          value
        end
      end
  end
end
