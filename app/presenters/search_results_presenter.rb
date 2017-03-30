require "cgi"

class SearchResultsPresenter

  # needed for *_show_url methods
  include Rails.application.routes.url_helpers

  attr_accessor :form_values, :fq, :query, :search_qs,
    :results, :pretty_facets,
    :page, :start, :end, :num_found, :num_pages

  def initialize(results, params, base_url)
    @base_url = base_url

    # Force all links to reset to page 1 so that if the user selects
    # a new facet or searches for a new term we show results starting
    # from page 1.
    params.page = 1

    # from params
    @params = params
    @form_values = @params.to_form_values(false)
    @fq = params.fq
    @query = params.q == "*" ? "" : CGI.unescape(params.q)
    @search_qs = params.to_user_query_string

    # from results
    @facets = results.facets
    @pretty_facets = set_remove_url_in_facets()
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
  end

  def pretty_fqs()
    @pretty_fqs ||= begin
      pretty = []
      @fq.each do |fq|
        tokens = fq.split(":")
        field = tokens.first
        value = CGI.unescape(tokens.last)[1..-2]   # remove surrounding quotes
        pretty << {
          original: fq,
          field: field,
          value: value,
          pretty: field + " > " + value,
          remove_url: @base_url + '?' + @params.to_user_query_string(fq)
        }
      end
      pretty
    rescue
      []
    end
  end

  def pages_urls()
    @pages_urls ||= begin
      urls = []
      qs = @search_qs.gsub(/page=[0-9]*/,"").chomp("&")
      (1..@num_pages).each do |p|
        urls << "#{@base_url}?#{qs}&page=#{p}"
      end
      urls
    end
  end

  private
    def set_remove_url_in_facets()
      # Each of the pretty_fqs represents a facet selected.
      # Find the corresponding facet/value and set the remove_url for it.
      pretty_fqs().each do |pretty_fq|
        field = pretty_fq[:field]
        value = pretty_fq[:value]
        url = pretty_fq[:remove_url]
        set_facet_remove_url(field, value, url)
      end
      @facets
    end

    def set_facet_remove_url(field, value, url)
      facet = @facets.select { |f| f.name == field }
      facet.each do |f|
        f.values.each do |v|
          if v.text == value
            v.remove_url = url
          end
        end
      end
    end
end
