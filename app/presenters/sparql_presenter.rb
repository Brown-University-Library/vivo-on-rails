class SparqlPresenter
  attr_accessor :query, :form_values # for page header
  attr_accessor :sparql, :results, :limit, :prefixes, :keys, :output, :message

  def initialize(sparql, query, limit, output, empty_search)
    @sparql = sparql
    @results = query.results
    @limit = limit
    @prefixes = query.prefixes
    @output = output
    @keys = []
    if @results.count > 0
      # Use the keys from the first row only.
      # OK in most instances but not always.
      @keys = @results.first.keys
    end
    if empty_search
      @message = ""
    else
      @message = "#{@results.count} results found"
    end
  end

  def text_results()
    text = ""
    text << "\n"
    @results.each do |result|
      # Notice that we don't use @keys in case each row has
      # a different set of columns (keys)
      result.keys.each do |key|
        text << result[key] + "\t"
      end
      text << "\n"
    end
    text
  end
end
