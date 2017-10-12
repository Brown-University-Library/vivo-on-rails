require "cgi"

class SearchResultsPresenter

  # needed for *_show_url methods
  include Rails.application.routes.url_helpers

  attr_accessor :form_values, :fq, :facets, :query, :search_qs, :results,
    :page, :start, :end, :num_found, :num_pages, :page_start, :page_end,
    :previous_url, :next_url,
    :remove_q_url, :facetSearchBaseUrl,
    :suggest_q, :suggest_url

  def initialize(results, params, base_url, base_facet_search_url)
    @base_url = base_url
    @facetSearchBaseUrl = base_facet_search_url

    # Force all links to reset to page 1 so that if the user selects
    # a new facet or searches for a new term we show results starting
    # from page 1.
    params.page = 1

    # from params
    @params = params
    @form_values = @params.to_form_values()
    @fq = params.fq
    @query = params.q == "*" ? "" : CGI.unescape(params.q)
    @search_qs = params.to_user_query_string()
    @remove_q_url = "#{@base_url}?#{params.to_user_query_string_no_q()}"

    @suggest_q = results.spellcheck_top_collation_query()
    if results.spellcheck_top_collation_query != nil
      @suggest_url = @remove_q_url + "&q=#{CGI.escape(suggest_q)}"
    end

    # from results
    @facets = results.facets
    @results = results.items
    set_urls_in_facets()
    set_remove_url_in_facets()

    @results.each do |item|
      item.uri = display_show_url(item.vivo_id)
      if item.type == "PEOPLE"
        item.thumbnail = "person_placeholder.jpg" if item.thumbnail == nil
      else
        item.thumbnail = "org_placeholder.jpg" if item.thumbnail == nil
      end
      if item.title != nil && item.title.length > 50
        item.title = item.title[0..47] + "..."
      end
    end

    @page = results.page
    @start = results.start
    @end = results.end
    @num_found = results.num_found
    @num_pages = results.num_pages

    pages_to_display = 10
    if @num_pages < pages_to_display
      @page_start = 1
      @page_end = @num_pages
    else
      if @page + pages_to_display <= @num_pages
        @page_start = @page
        @page_end = @page + pages_to_display - 1
      else
        @page_start = @num_pages - pages_to_display + 1
        @page_end = @num_pages
      end
    end

    @previous_url = page_url(@page-1)
    @next_url = page_url(@page+1)
  end

  def pages_urls()
    @pages_urls ||= begin
      urls = []
      (1..@num_pages).each do |p|
        urls << page_url(p)
      end
      urls
    end
  end

  def page_url(page_number)
    qs = @search_qs.gsub(/page=[0-9]*/,"").chomp("&")
    "#{@base_url}?#{qs}&page=#{page_number}"
  end

  private
    def set_urls_in_facets()
      # this loops through _all_ the facet/values
      @facets.each do |f|
        f.values.each do |v|
          qs = @search_qs + "&fq=" + f.to_qs(v.text)
          v.add_url = @base_url + "?" + qs
        end
      end
    end

    def set_remove_url_in_facets()
      # this loops _only_ through the active filters
      @fq.each do |fq|
        facet = @params.facet_for_field(fq.field)
        next if facet == nil

        # set the remove URL in the facet/value
        remove_url = @base_url + '?' + @params.to_user_query_string(fq)
        facet.set_remove_url_for(fq.value, remove_url)

        # ...and in the fq
        fq.title = facet.title
        fq.remove_url = remove_url
      end
    end
end
