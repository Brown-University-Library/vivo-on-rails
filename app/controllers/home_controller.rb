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
    params = SolrLite::SearchParams.from_query_string(request.query_string)
    puts "== Calculated params"
    puts params
    puts ""
    if params.facets.count == 0
      params.facets = ["record_type", "affiliations", "research_areas"]
    end
    params.q = "*" if params.q == ""
    search_results = searcher.search(params)
    @form_values = params.to_form_values(false)
    @fq = params.fq
    @pretty_fqs = pretty_fqs(params)
    @facets = search_results.facets
    @faculty_list = search_results.items
    @page = search_results.page
    @start = search_results.start
    @end = search_results.end
    @num_found = search_results.num_found
    @num_pages = search_results.num_pages
    @query = params.q == "*" ? "" : CGI.unescape(params.q)
    @search_qs = params.to_user_query_string
    @page_qs = @search_qs.gsub(/page=[0-9]*/,"").chomp("&")
    render "results"
  end

  def pretty_fqs(params)
    params.fq.map do |fq|
      {
        original: fq,
        pretty: CGI::unescape(fq).gsub('"', '').gsub(":", " > "),
        remove_url: home_search_url() + '?' + params.facet_remove_query_string(fq)
      }
    end
  end
end
