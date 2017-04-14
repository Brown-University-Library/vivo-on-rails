require "./lib/solr_lite/filter_query.rb"
require "./lib/solr_lite/facet_field.rb"
module SolrLite
  class SearchParams
    attr_accessor :q, :fq, :facets, :page, :page_size, :fl, :sort

    DEFAULT_PAGE = 1
    DEFAULT_PAGE_SIZE = 20

    def initialize(q = "", fq = [], facets = [], page = DEFAULT_PAGE, page_size = DEFAULT_PAGE_SIZE)
      @q = q
      @fq = fq          # array of FilterQuery
      @facets = facets  # array of FacetField
      @page = page
      @page_size = page_size
      @fl = nil
      @sort = ""
    end

    def facet_for_field(field)
      @facets.find {|f| f.name == field}
    end

    def set_facet_remove_url(field, value, url)
      facet = facet_for_field(field)
      if facet != nil
        facet.set_remove_url_for(value, url)
      end
    end

    def start_row()
      (@page - 1) * @page_size
    end

    def star_row=(start)
      # recalculate the page
      if @page_size == 0
        @page = 0
      else
        @page = (start / @page_size) + 1
      end
      nil
    end

    # Returns the string that we need render on the Browser to execute
    # a search with the current parameters.
    #
    # facet_to_ignore: a FilterQuery object with a value to ignore when
    #   creating the query string.
    # q_override: a string with a Solr query to use instead of the current q value
    def to_user_query_string(facet_to_ignore = nil, q_override = nil)
      qs = ""
      q_value = q_override != nil ? q_override : @q
      if q_value != "" && @q != "*"
        qs += "&q=#{@q}"
      end
      @fq.each do |filter|
        if facet_to_ignore != nil && filter.solr_value == facet_to_ignore.solr_value
          # don't add this to the query string
        else
          qs += "&fq=#{filter.qs_value}"
        end
      end
      qs += "&rows=#{@page_size}" if @page_size != DEFAULT_PAGE_SIZE
      qs += "&page=#{@page}" if @page != DEFAULT_PAGE
      qs += "&sort=#{@sort}" if sort != ""
      qs
    end

    def to_user_query_string_no_q()
      to_user_query_string(nil, '')
    end

    # Returns the string that we need to pass Solr to execute a search
    # with the current parameters.
    def to_solr_query_string()
      qs = ""
      if @q != ""
        qs += "&q=#{@q}"
      end
      @fq.each do |filter|
        qs += "&fq=#{filter.solr_value}"
      end
      qs += "&rows=#{@page_size}"
      qs += "&start=#{start_row()}"
      if sort != ""
        qs += "&sort=#{@sort}"
      end
      if @facets.count > 0
        qs += "&facet=on"
        @facets.each do |f|
          qs += "&facet.field=#{f.name}&f.#{f.name}.facet.mincount=1"
        end
      end
      qs
    end

    # Returns an array of values that can be added to an HTML form
    # to represent the current search parameters. Notice that we do
    # NOT include the `q` parameter there is typically an explicit
    # HTML form value for it on the form.
    def to_form_values()
      values = []

      # We create an individual fq_n HTML form value for each
      # fq value because Rails does not like the same value on the form.
      @fq.each_with_index do |filter, i|
        values << {name: "fq_#{i}", value: filter.qs_value}
      end

      values << {name: "rows", value: @page_size} if @page_size != DEFAULT_PAGE_SIZE
      values << {name: "page", value: @page} if @page != DEFAULT_PAGE
      values << {name: "sort", value: @sort} if sort != ""
      values
    end

    def to_s()
      "q=#{@q}\nfq=#{@fq}"
    end

    def self.from_query_string(qs, facet_fields = [])
      params = SearchParams.new
      params.facets = facet_fields
      tokens = qs.split("&")
      tokens.each do |token|
        values = token.split("=")
        name = values[0]
        value = values[1]
        fq = nil
        next if value == nil || value.empty?
        case
        when name == "q"
          params.q = value
        when name == "rows"
          params.page_size = value.to_i
        when name == "page"
          params.page = value.to_i
        when name == "fq" || name.start_with?("fq_")
          # Query string contains fq when _we_ build the query string, for
          # example as the user clicks on different facets on the UI.
          # A query string can have multiple fq values.
          #
          # Query string contains fq_n when _Rails_ pushes HTML FORM values to
          # the query string. Rails does not like duplicate values in forms
          # and therefore we force them to be different by appending a number
          # to them (fq_1, f1_2, ...)
          fq = FilterQuery.from_query_string(value)
          if fq != nil
            params.fq << fq
          end
        end
      end
      params
    end
  end
end
