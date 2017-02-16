require "cgi"

class SearchResultsPresenter
  attr_accessor :form_values, :fq, :facets,
    :results, :page, :start, :end, :num_found, :num_pages,
    :query, :search_qs

  def initialize(base_url, search_params)
    @base_url = base_url
    @params = search_params
    @form_values = []
    @fq = []
    @facets = []
    @results = []
    @page = 0
    @start = 0
    @end = 0
    @num_found = 0
    @num_pages = 0
    @query = ""
    @search_qs = ""
  end

  def pages_urls()
    @pages_urls ||= begin
      urls = []
      qs = @search_qs.gsub(/page=[0-9]*/,"").chomp("&")
      (1..@num_pages).each do |p|
        urls << "#{@base_url}?#{qs}&page=#{p}"
      end
      puts "calculated pages urls #{urls.count}"
      urls
    end
  end

  def pretty_fqs()
    # TODO: remove dependency on params.to_user_querystring()
    @pretty_fqs ||= begin
      @fq.map do |fq|
        {
          original: fq,
          pretty: CGI::unescape(fq).gsub('"', '').gsub(":", " > "),
          remove_url: @base_url + '?' + @params.to_user_query_string(fq)
        }
      end
    end
  end

  def self.from_results(results, params, base_url)
    p = SearchResultsPresenter.new(base_url, params)
    p.form_values = params.to_form_values(false)
    p.fq = params.fq
    p.facets = results.facets
    p.results = results.items
    p.page = results.page
    p.start = results.start
    p.end = results.end
    p.num_found = results.num_found
    p.num_pages = results.num_pages
    p.query = params.q == "*" ? "" : CGI.unescape(params.q)
    p.search_qs = params.to_user_query_string
    p
  end
end
