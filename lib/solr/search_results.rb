module Solr
  class SearchResults
    attr_accessor :items
    def initialize(solr_response)
      @solr_response = solr_response
      # client to set this value with custom representation of solr_docs
      @items = []
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
      @solr_response["facet_counts"]["facet_fields"]
    end
  end
end
