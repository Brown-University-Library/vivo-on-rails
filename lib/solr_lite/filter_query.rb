module SolrLite
  # Represents an "fq" in Solr. Field is the field to filter by
  # and value the value to filter by. In a Solr query are represented
  # as "fq=field:value"
  class FilterQuery
    attr_accessor :field, :value, :solr_value, :qs_value, :form_value
    attr_accessor :title, :remove_url

    def initialize(field, values)
      @field = field
      @value = values.join("|")
      @solr_value = to_solr_fq_value(field, values)
      @qs_value = "#{field}"
      values.each do |v|
        @qs_value += "|#{CGI.escape(v)}"    # URL friendly (no : or quotes)
      end
      @form_value = "#{field}|#{@value}"    # HTML Form friendly (no encoding, the form auto-encodes on POST)
      @title = field                        # default to field name
      @remove_url = nil
    end

    # qs is assumed to be the value taken from the query string
    # in the form `field|value` or `field|value1|valueN`.
    #
    # Sometimes(*) the string comes URL encoded, for example:
    #     `field|hello`
    #     `field|hello%20world`
    # CGI.unespace handles these cases nicer than URL.decode
    #
    # (*) Values coming from HTML forms submitted via HTTP POST tend
    # to be encoded slighly different than value submitted via
    # HTTP GET requests.
    def self.from_query_string(qs)
      tokens = CGI.unescape(qs).split("|")
      return nil if tokens.count < 2
      field = ""
      values = []
      tokens.each_with_index do |token, i|
        if i == 0
          field = token
        else
          values << token
        end
      end
      FilterQuery.new(field, values)
    end

    private
      # Creates a filter query (fq) string as needed by Solr from
      # an array of values. Handles single and multi-value gracefully.
      # For single-value it returns "(field:value)". For multi-value
      # it returns "(field:value1) OR (field:value2)"
      def to_solr_fq_value(field, values)
        solr_value = ""
        values.each_with_index do |v, i|
          solr_value += '(' + field + ':"' + v + '")'
          lastValue = (i == (values.length-1))
          if !lastValue
            solr_value += " OR "
          end
        end
        # Very important to escape the : otherwise URL.parse throws an error in Linux
        CGI.escape(solr_value)
      end
  end # class
end # module
