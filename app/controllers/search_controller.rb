class SearchController < ApplicationController
  def index
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url)
    params = SolrLite::SearchParams.from_query_string(request.query_string)
    if params.facets.count == 0
      params.facets = ["record_type", "affiliations", "research_areas", "published_in"]
    end
    params.q = "*" if params.q == ""
    search_results = searcher.search(params)
    @presenter = SearchResultsPresenter.new(search_results, params, search_url())
    render "results"
  end
end
