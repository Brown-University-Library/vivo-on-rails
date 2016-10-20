class HomeController < ApplicationController
  def index
  end
  def search
    solr_url = ENV["SOLR_URL"]
    searcher = FacultySearch.new(solr_url)
    params = Solr::SearchParams.from_query_string(request.query_string)
    if params.facets.count == 0
      params.facets = ["record_type", "affiliations.name"]
    end
    search_results = searcher.search(params)
    @facets = search_results.facets
    @faculty_list = search_results.items
    @num_found = search_results.num_found
    @query = params.q
    @search_qs = params.to_user_query_string
    render "results"
  end
end
