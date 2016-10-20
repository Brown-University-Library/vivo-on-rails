require "./lib/solr/facet_field.rb"
module Solr
  class SearchParams
    attr_accessor :q, :fq, :facets, :page, :page_size

    def initialize(q = "", fq = [], facets = [], page = 1, page_size = 10)
      @q = q
      @fq = fq
      @facets = facets
      @page = page
      @page_size = page_size
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
      qs = "q=#{@q}"
      @fq.each do |filter|
        qs += "&fq=#{filter}"
      end
      qs += "&rows=#{@page_size}"
      qs += "&start=#{start_row()}"
      qs
    end

    def to_solr_query_string
      qs = if q == "" then "q=*" else "q=#{@q}" end
      @fq.each do |filter|
        qs += "&fq=#{filter}"
      end
      qs += "&rows=#{@page_size}"
      qs += "&start=#{start_row()}"
      if @facets.count > 0
        qs += "&facet=on"
        @facets.each do |f|
          qs += "&facet.field=#{f}&f.#{f}.facet.mincount=1"
        end
      end
      qs
    end

    def self.from_query_string(qs, facets = [])
      params = SearchParams.new
      params.facets = facets
      tokens = qs.split("&")
      qs_start = nil
      tokens.each do |token|
        values = token.split("=")
        name = values[0]
        value = values[1]
        next if value == nil || value.empty?
        case name
        when "q"
          params.q = value
        when "fq"
          params.fq << value
        when "rows"
          params.page_size = value.to_i
        when "start"
          qs_start = value.to_i
        # when "facet.field"
        #   params.facets << value
        end
      end
      if qs_start != nil
        # Do this last to make sure we use the page_size (rows)
        # indicated in the query string (even it it comes
        # after the rows parameter within the query string.)
        params.star_row = qs_start
      end
      params
    end
  end
end
