class SearchController < ApplicationController
  # Normal search. Returns search results as HTML.
  def index
    execute_search()
    render "results"
  end

  # Returns the facet values (as JSON) for a search.
  # Use by the modals forms that show all values for a facet.
  def facets
    facet_name = request.params["f_name"]
    if facet_name == nil
      render :json => nil
      return
    end
    execute_search(-1)
    facet_data = @presenter.facets.find {|f| f.name == facet_name }
    render :json => facet_data.values
  end

  private
    def execute_search(facet_limit = nil)
      solr_url = ENV["SOLR_URL"]
      searcher = Search.new(solr_url)
      params = SolrLite::SearchParams.from_query_string(request.query_string, facets_fields())
      params.q = "*" if params.q == ""
      params.facet_limit = facet_limit if facet_limit != nil

      if request.params["home"] != nil
        # default to people if coming from the home page
        params.fq << SolrLite::FilterQuery.new("record_type", "PEOPLE")
      end

      if ENV["USE_VIVO_SOLR"] == "true"
        search_results = searcher.search(params, [])
      else
        not_hidden_fq = SolrLite::FilterQuery.new("hidden_b", "false")
        search_results = searcher.search(params, [not_hidden_fq])
      end
      @presenter = SearchResultsPresenter.new(search_results, params, search_url(), base_facet_search_url())
      @presenter
    end

    def facets_fields()
      f = []
      f << SolrLite::FacetField.new("record_type", "Type")
      f << SolrLite::FacetField.new("affiliations", "Affiliations")
      f << SolrLite::FacetField.new("research_areas", "Research Areas")
      f << SolrLite::FacetField.new("published_in", "Published In")
      f
    end

    def base_facet_search_url()
      # Base this value of the original search URL so that we preserve all
      # the search parameters.
      url = request.original_url.sub("/search", "/search_facets")
      if !url.include?("?")
        # This is to make sure we can safely add a query string parameter
        # (in the JavaScript used in the view) by just appending "&a=b".
        url += "?"
      end
      url
    end
end
