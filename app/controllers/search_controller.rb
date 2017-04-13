class SearchController < ApplicationController
  def index
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url)
    params = SolrLite::SearchParams.from_query_string(request.query_string, facets_fields())
    params.q = "*" if params.q == ""
    search_results = searcher.search(params)
    @presenter = SearchResultsPresenter.new(search_results, params, search_url())
    render "results"
  end

  def facets_fields
    # TODO: should this be configurable?
    f = []
    f << SolrLite::FacetField.new("record_type", "Type")
    f << SolrLite::FacetField.new("affiliations", "Affiliations")
    f << SolrLite::FacetField.new("research_areas", "Research Areas")
    f << SolrLite::FacetField.new("published_in", "Published In")
    f
  end
end
