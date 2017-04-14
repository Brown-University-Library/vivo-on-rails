require "cgi"

class SearchResultsPresenter

  # needed for *_show_url methods
  include Rails.application.routes.url_helpers

  attr_accessor :form_values, :fq, :facets, :query, :search_qs, :results,
    :page, :start, :end, :num_found, :num_pages, :page_start, :page_end,
    :previous_url, :next_url,
    :remove_q_url

  def initialize(results, params, base_url)
    @base_url = base_url

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

    # from results
    set_remove_url_in_facets()
    @facets = results.facets
    @results = results.items

    @results.each do |item|
      if item.type == "PEOPLE"
        item.uri = faculty_show_url(item.vivo_id)
        item.thumbnail = "person_placeholder.jpg" if item.thumbnail == nil
      else
        item.uri = organization_show_url(item.vivo_id)
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
    def set_remove_url_in_facets()
      @fq.each do |fq|
        remove_url = @base_url + '?' + @params.to_user_query_string(fq)

        # set the remove URL in the facet/value
        facet = @params.facet_for_field(fq.field)
        facet.set_remove_url_for(fq.value, remove_url)

        # ...and in the fq
        fq.title = facet.title
        fq.remove_url = remove_url
      end
    end
end
