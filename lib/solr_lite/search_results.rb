require "./lib/solr_lite/facet_field.rb"
module SolrLite
  # TODO: this should be renamed to SolrResponse
  class SearchResults
    attr_accessor :items
    def initialize(solr_response)
      @solr_response = solr_response
      # client to set this value with custom representation of solr_docs
      @items = []
      @facets_cache = nil
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
      pages = (num_found / page_size).to_i
      pages +=1 if (num_found % page_size) != 0
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

    # Array of FacetFields
    def facets
      @facets_cache ||= begin
        return [] if @solr_response["facet_counts"] == nil
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
