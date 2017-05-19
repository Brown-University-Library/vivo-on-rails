require "./lib/sparql/query.rb"

class SparqlController < ApplicationController
  skip_before_filter :authenticate_user!

  def query
    @presenter = execute_from_request()
    render "query", layout: false
  end

  def execute_from_request
    sparql = params[:sparql] || default_sparql()
    limit = (params[:limit] || "100").to_i
    output = params[:output] || "html"

    sparql_exec = sparql
    if limit > 0
      sparql_exec += " limit #{limit}"
    end
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql_exec)
    SparqlPresenter.new(sparql, query, limit, output)
  end

  def default_sparql()
    "SELECT ?s ?p ?o\nWHERE {\n  ?s ?p ?o .\n}"
  end
end
