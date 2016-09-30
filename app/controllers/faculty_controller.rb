class FacultyController < ApplicationController
  def index
    @faculty_list = Faculty.all()
  end

  def show
    id = params[:id]
    @faculty = Faculty.get_one(id)
  end

  def search
    solr_url = ENV["SOLR_URL"]
    searcher = FacultySearch.new(solr_url)
    search_term = params[:query]
    search_results = searcher.search(search_term)
    @faculty_list = search_results.items
    @num_found = search_results.num_found
    @query = search_term
    render "index"
  end
end
