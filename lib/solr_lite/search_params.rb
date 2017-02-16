require "./lib/solr_lite/facet_field.rb"
module SolrLite
  class SearchParams
    attr_accessor :q, :fq, :facets, :page, :page_size, :fl, :sort

    def initialize(q = "", fq = [], facets = [], page = 1, page_size = 20)
      @q = q
      @fq = fq
      @facets = facets
      @page = page
      @page_size = page_size
      @fl = nil
      @sort = ""
    end

    def start_row
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

    def to_user_query_string
      qs = ""
      if @q != "" && @q != "*"
        qs += "&q=#{@q}"
      end
      if @fq.count > 0
        @fq.each do |filter|
          qs += "&fq=#{filter}"
        end
      end
      # TODO: omit if using defaults
      qs += "&rows=#{@page_size}"
      qs += "&page=#{@page}"
      if sort != ""
        qs += "&sort=#{@sort}"
      end
      qs
    end

    def facet_remove_query_string(facet)
      qs = ""
      if @q != "" && @q != "*"
        qs += "&q=#{@q}"
      end
      if @fq.count > 0
        @fq.each do |filter|
          if filter != facet
            qs += "&fq=#{filter}"
          else
            # qs += "&removed=#{filter}"
          end
        end
      end
      # TODO: omit if using defaults
      qs += "&rows=#{@page_size}"
      qs += "&page=#{@page}"
      if sort != ""
        qs += "&sort=#{@sort}"
      end
      qs
    end

    def to_solr_query_string
      qs = ""
      if @q != ""
        qs += "&q=#{@q}"
      end
      if @fq.count > 0
        @fq.each do |filter|
          qs += "&fq=#{filter}"
        end
      end
      qs += "&rows=#{@page_size}"
      qs += "&start=#{start_row()}"
      if sort != ""
        qs += "&sort=#{@sort}"
      end
      if @facets.count > 0
        qs += "&facet=on"
        @facets.each do |f|
          qs += "&facet.field=#{f}&f.#{f}.facet.mincount=1"
        end
      end
      qs
    end

    def to_form_values(include_q)
      values = []
      if include_q && @q != ""
        values << {name: "q", value: @q}
      end
      @fq.each_with_index do |filter, i|
        values << {name: "fq_#{i}", value: filter}
      end
      values << {name: "rows", value: @page_size}
      values << {name: "start", value: start_row()}
      values << {name: "sort", value: @sort}
      values
    end

    def to_s
      "q=#{@q}\nfq=#{@fq}"
    end

    def self.from_query_string(qs, facets = [])
      params = SearchParams.new
      params.facets = facets
      tokens = qs.split("&")
      tokens.each do |token|
        values = token.split("=")
        name = values[0]
        value = values[1]
        next if value == nil || value.empty?
        case
        when name == "q"
          params.q = value
        when name == "rows"
          params.page_size = value.to_i
        when name == "page"
          params.page = value.to_i
        when name == "fq"
          # Query string contains fq when we build the query string, for
          # example as the user clicks on different facets on the UI.
          # A query string can have multiple fq values.
          params.fq << value
        when name.start_with?("fq_")
          # Query string contains fq_n when Rails pushes HTML FORM values to
          # the query string. Rails does not like duplicate values in forms
          # and therefore we force them to be different by appending a number
          # to them (fq_1, f1_2, ...)
          params.fq << CGI::unescape(value)
        end
      end

      deleted_fq = []
      tokens.each do |token|
        values = token.split("=")
        name = values[0]
        value = values[1]
        next if value == nil || value.empty?
        if name == "fq" && value.first == "-"
          deleted_fq << value[1..-1]
          deleted_fq << value
        end
      end
      # byebug
      puts params.fq
      puts deleted_fq
      test_a = params.fq - deleted_fq
      params.fq = test_a
      puts params.fq
      params
    end
  end
end
