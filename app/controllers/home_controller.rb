class HomeController < ApplicationController
  def index
  end
  def search
    solr_url = ENV["SOLR_URL"]
    searcher = FacultySearch.new(solr_url)
    search_term = params[:query]
    search_results = searcher.search(search_term)
    @facets = search_results.facets
    @faculty_list = search_results.items
    @num_found = search_results.num_found
    @query = search_term
    render "results"
  end
end
