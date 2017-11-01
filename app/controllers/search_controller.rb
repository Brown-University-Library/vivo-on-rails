class SearchController < ApplicationController
  # Advanced search.
  def advanced
    q = build_q_from_params()
    if params["search"] == "true" && q != ""
      redirect_to "#{search_url()}?q=#{q}"
    else
      @presenter = AdvancedSearchPresenter.new(params)
      render "advanced"
    end
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not render advanced search. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  # Normal search. Returns search results as HTML.
  def index
    execute_search()
    if @presenter.num_found == 0
      Rails.logger.warn("No results were found. Search: #{@presenter.search_qs}")
    end
    render "results"
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not render search. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  # Returns the facet values (as JSON) for a search.
  # Use by the modals forms that show all values for a facet.
  def facets
    facet_name = request.params["f_name"]
    if facet_name == nil
      render :json => nil
      return
    end
    execute_search(-1)
    facet_data = @presenter.facets.find {|f| f.name == facet_name }
    render :json => facet_data.values
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not render facets as JSON. Exception: #{ex} \r\n #{backtrace}")
    render :json => nil, status: 500
  end

  private
    def execute_search(facet_limit = nil)
      solr_url = ENV["SOLR_URL"]
      images_url = ENV["IMAGES_URL"]
      searcher = Search.new(solr_url, images_url)
      params = SolrLite::SearchParams.from_query_string(request.query_string, facets_fields())
      params.q = "*" if params.q == ""
      params.facet_limit = facet_limit if facet_limit != nil
      search_results = searcher.search(params)
      @presenter = SearchResultsPresenter.new(search_results, params, search_url(), base_facet_search_url())
      @presenter
    end

    def facets_fields()
      f = []
      f << SolrLite::FacetField.new("record_type", "Type")
      f << SolrLite::FacetField.new("affiliations", "Brown Affiliations")
      f << SolrLite::FacetField.new("research_areas", "Research Areas")
      f << SolrLite::FacetField.new("published_in", "Published In")
      f
    end

    def base_facet_search_url()
      # Base this value of the original search URL so that we preserve all
      # the search parameters.
      url = request.original_url.sub("/search", "/search_facets")
      if !url.include?("?")
        # This is to make sure we can safely add a query string parameter
        # (in the JavaScript used in the view) by just appending "&a=b".
        url += "?"
      end
      url
    end

    def build_q_from_params()
      q = ""
      q = build_q(q, params["title_t"], "title_t")
      q = build_q(q, params["department_t"], "department_t")
      q = build_q(q, params["name_t"], "name_t")
      q
    end

    def build_q(q, value, field)
      if value == nil || value.empty?
        q
      else
        if q == ""
          "#{field}:\"#{value}\""
        else
          q + "+AND+#{field}:\"#{value}\""
        end
      end
    end
end
