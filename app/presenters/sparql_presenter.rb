class SparqlPresenter
  attr_accessor :query, :form_values # for page header
  attr_accessor :sparql, :results, :limit, :prefixes, :keys, :output

  def initialize(sparql, query, limit, output)
    @sparql = sparql
    @results = query.results
    @limit = limit
    @prefixes = query.prefixes
    @output = output
    @keys = []
    if @results.count > 0
      @keys = @results.first.keys
    end
  end
end
