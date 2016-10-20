require "./lib/solr/facet_field.rb"
module Solr
  class SearchResults
    attr_accessor :items
    def initialize(solr_response)
      @solr_response = solr_response
      # client to set this value with custom representation of solr_docs
      @items = []
      @facets_cache = nil
    end

    # total number documents found in solr
    # usually larger than solr_docs.count
    def num_found
      @solr_response["response"]["numFound"]
    end

    # raw solr_docs
    def solr_docs
      @solr_response["response"]["docs"]
    end

    def facets
      @facets_cache ||= begin
        cache = []
        solr_facets = @solr_response["facet_counts"]["facet_fields"]
        solr_facets.each do |facet|
          field = FacetField.new(facet[0])
          values = facet[1]
          pairs = values.count/2
          for pair in (1..pairs)
            index = (pair-1) * 2
            text = values[index]
            count = values[index+1]
            field.add_value(text, count)
          end
          cache << field
        end
        cache
      end
    end
  end
end
