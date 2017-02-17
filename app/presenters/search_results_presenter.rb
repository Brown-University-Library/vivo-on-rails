require "cgi"

class SearchResultsPresenter
  attr_accessor :form_values, :fq, :query, :search_qs,
    :facets, :results, :page, :start, :end, :num_found, :num_pages

  def initialize(results, params, base_url)
    @base_url = base_url

    # from params
    @params = params
    @form_values = params.to_form_values(false)
    @fq = params.fq
    @query = params.q == "*" ? "" : CGI.unescape(params.q)
    @search_qs = params.to_user_query_string

    # from results
    @facets = facets_with_remove_urls(results.facets)
    @results = results.items
    @page = results.page
    @start = results.start
    @end = results.end
    @num_found = results.num_found
    @num_pages = results.num_pages
  end

  def facets_with_remove_urls(facets)
    # pretty_fqs has the list of active filter queries which amounts to
    # the selected facets. We loop through all these pretty_fqs and find
    # the matching facet/value in the list of facets and set the link
    # that can be used to unselect that facet/value.
    pretty_fqs.each do |pretty_fq|
      # facets for this field
      ff = facets.select { |f| f.name == pretty_fq[:field] }
      ff.each do |f|
        # values for this facet
        f.values.each do |v|
          if v.text == pretty_fq[:value]
            # this is the facet/value that we have selected,
            # set the proper URL to remove it.
            v.remove_url = pretty_fq[:remove_url]
          end
        end
      end
    end
    facets
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
end
