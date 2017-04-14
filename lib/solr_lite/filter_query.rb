module SolrLite
  # Represents an "fq" in Solr. Field is the field to filter by
  # and value the value to filter by. In a Solr query are represented
  # as "fq=field:value"
  class FilterQuery
    attr_reader :solr_value, :field, :value
    attr_accessor :title, :remove_url
    def initialize(field, value)
      @field = field
      @value = value
      @solr_value = "#{field}:\"#{value}\""
      @title = field      # default to field
      @remove_url = nil
    end

    # qs is assumed to be value taken from the query string
    # in the form `field:"value"`. Sometimes the string comes
    # URL encoded, for example:
    #     `field%3A"value"`
    #     `field%3A"value%2C+whatever`
    # CGI.unespace handles these cases nicer than URL.decode
    def self.from_query_string(qs)
      tokens = CGI.unescape(qs).split(":")
      return nil if tokens.count != 2
      field = tokens[0]
      value = strip_quotes(tokens[1])
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
