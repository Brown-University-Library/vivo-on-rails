class SearchResultsPresenter
  attr_accessor :form_values, :fq, :pretty_fqs, :facets,
    :faculty_list, :page, :start, :end, :num_found, :num_pages,
    :query, :search_qs

  def initialize()
    @form_values = []
    @fq = []
    @pretty_fqs = []
    @facets = []
    @faculty_list = []
    @page = 0
    @start = 0
    @end = 0
    @num_found = 0
    @num_pages = 0
    @query = ""
    @search_qs = ""
  end

  def page_qs()
    @search_qs.gsub(/page=[0-9]*/,"").chomp("&")
  end

  def self.pretty_fqs(params, base_url)
    params.fq.map do |fq|
      {
        original: fq,
        pretty: CGI::unescape(fq).gsub('"', '').gsub(":", " > "),
        remove_url: base_url + '?' + params.to_user_query_string(fq)
      }
    end
  end

  def self.from_results(results, params, base_url)
    p = SearchResultsPresenter.new
    p.form_values = params.to_form_values(false)
    p.fq = params.fq
    p.pretty_fqs = pretty_fqs(params, base_url)
    p.facets = results.facets
    p.faculty_list = results.items
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
