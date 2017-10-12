require "./lib/solr_lite/facet_field.rb"
module SolrLite
  # TODO: this should be renamed to SolrResponse
  class SearchResults
    attr_accessor :items
    def initialize(solr_response, params)
      @solr_response = solr_response
      @params = params
      set_facet_values()

      # This value can be set by the client if we want to use a custom
      # representation of solr_docs
      @items = []
    end

    def ok?
      return true if status == 0
      return true if status >= 200 && status <= 299
      false
    end

    def status
      return -1 if @solr_response["responseHeader"] == nil
      @solr_response["responseHeader"]["status"]
    end

    def error_msg
      return "" if @solr_response["error"] == nil
      return "" if @solr_response["error"]["msg"] == nil
      @solr_response["error"]["msg"]
    end

    # Total number documents found in solr
    # usually larger than solr_docs.count
    def num_found
      @solr_response["response"]["numFound"]
    rescue
      0
    end

    def num_pages
      return 0 if page_size == 0
      pages = (num_found / page_size).to_i
      pages += 1 if (num_found % page_size) != 0
      pages
    end

    def page_size
      @solr_response["responseHeader"]["params"]["rows"].to_i
    rescue
      0
    end

    # Start position for retrieval (used for pagination)
    def start
      @solr_response["response"]["start"].to_i
    rescue
      0
    end

    def end
      [start + page_size, num_found].min
    end

    def page
      return 1 if page_size == 0 # fail safe
      (start / page_size) + 1
    end

    # Raw solr_docs
    def solr_docs
      @solr_response["response"]["docs"]
    end

    def facets
      @params.facets
    end

    def spellcheck()
      @spellcheck ||= @solr_response.fetch("spellcheck",{})
    end

    def spellcheck_suggestions()
      @spellcheck_suggestions ||= spellcheck().fetch("suggestions",[])
    end

    def spellcheck_collations()
      @spellcheck_collations ||= begin
        collations = spellcheck().fetch("collations",nil)
        if collations != nil
          if collations.kind_of?(Array)
            # We must be in Solr6, use the collation information as-is
          else
            # uh-oh...
            []
          end
        else
          # We must be on Solr4, mimic the structure of the Solr6 results
          # which is an array in the form:
          #
          #   ["collation", {"collationQuery": "wordA"}, "collation", {"collationQuery": "wordB"}, ...]
          #
          # As a reference, the structure in Solr4 is slightly different in that
          # the collationQuery information is in an array within an array:
          #
          #   ["collation", ["collationQuery", "wordA"], "collation"["collationQuery", "wordB"], ...]
          #
          collations = []
          suggestions = spellcheck_suggestions()
          suggestions.each_with_index do |x, i|
            if x == "collation"
              collationQuery = suggestions[i+1]
              word = collationQuery[1]
              collations << "collation"
              collations << {"collationQuery" => word}
            end
          end
        end
        collations
      end
    end

    def spellcheck_correctly_spelled()
      spellcheck().fetch("correctlySpelled", true)
    end

    def spellcheck_top_collation_query()
      collations = spellcheck_collations()
      return nil if collations.length < 2
      top_collation = collations[1] || {}
      top_collation.fetch("collationQuery", nil)
    end

    def set_facet_values()
      return if @solr_response["facet_counts"] == nil
      solr_facets = @solr_response["facet_counts"]["facet_fields"]
      solr_facets.each do |solr_facet|
        # solr_facet is an array with two elements, e.g.
        # ["record_type", ["PEOPLE", 32, "ORGANIZATION", 4]]
        #
        # the first element has the field for the facet (record_type)
        # the second element is an array with of value/count pairs (PEOPLE/32, ORG/4)
        field_name = solr_facet[0]
        facet_field = @params.facet_for_field(field_name)
        values = solr_facet[1]
        pairs = values.count/2
        for pair in (1..pairs)
          index = (pair-1) * 2
          text = values[index]
          count = values[index+1]
          facet_field.add_value(text, count)
        end
      end
      # TODO: make sure we sort the FacetField.VALUES descending by count
    end
  end # class
end # module
