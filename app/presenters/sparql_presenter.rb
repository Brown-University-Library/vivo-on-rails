class SparqlPresenter
  attr_accessor :query, :form_values # for page header
  attr_accessor :sparql, :results, :limit, :prefixes, :keys, :output, :message,
    :queries

  def initialize(sparql, query, limit, output, empty_search)
    @sparql = sparql
    @results = query.results
    @limit = limit
    @prefixes = query.prefixes
    @output = output
    @queries = predefined_queries()
    if @sparql.strip.length == 0
      @sparql = queries[0][:sparql]
    end
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

  def predefined_queries()
    queries = []

    query = {name: "defaut", sparql: "SELECT ?s ?p ?o\nWHERE {\n  ?s ?p ?o .\n}"}
    queries << query

    query = {name: "faculty", sparql: ""}
    query[:sparql] = <<-END_SPARQL
select distinct ?uri ?name ?title ?image
where {
  ?uri ?p core:FacultyMember .
  ?uri rdfs:label ?name .
  ?uri core:preferredTitle ?title .
}
    END_SPARQL

    queries << query
    queries
  end
end
