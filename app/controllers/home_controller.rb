require "cgi"
class HomeController < ApplicationController
  def index
  end

  def about
    render
  end

  def search
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url)
    params = Solr::SearchParams.from_query_string(request.query_string)
    if params.facets.count == 0
      params.facets = ["record_type", "affiliations"]
    end
    search_results = searcher.search(params)
    @fq = pretty_fq(params.fq)
    @facets = search_results.facets
    @faculty_list = search_results.items
    @page = search_results.page
    @start = search_results.start
    @end = search_results.end
    @num_found = search_results.num_found
    @num_pages = search_results.num_pages
    @query = params.q
    @search_qs = params.to_user_query_string
    @page_qs = @search_qs.gsub(/page=[0-9]*/,"").chomp("&")
    render "results"
  end

  def pretty_fq(fq)
    fq.map do |x|
      CGI::unescape(x).gsub('"', '').gsub(":", " > ")
    end
  end
end
