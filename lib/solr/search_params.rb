require "./lib/solr/facet_field.rb"
module Solr
  class SearchParams
    attr_accessor :q, :fq, :facets, :page, :page_size, :fl

    def initialize(q = "", fq = [], facets = [], page = 1, page_size = 20)
      @q = q
      @fq = fq
      @facets = facets
      @page = page
      @page_size = page_size
      @fl = nil
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
      # TODO: omit if using defaults
      qs += "&rows=#{@page_size}"
      qs += "&page=#{@page}"
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
        when "page"
          params.page = value.to_i
        end
      end
      params
    end
  end
end
