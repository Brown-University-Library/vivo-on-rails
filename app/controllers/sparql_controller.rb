require "./lib/sparql/query.rb"

class SparqlController < ApplicationController
  skip_before_filter :authenticate_user!

  def query
    @presenter = execute_from_request()
    if params["TextExport"] == "1"
      render plain: @presenter.text_results()
    else
      render "query"
    end
  end

  def execute_from_request
    sparql = params[:sparql] || ""
    limit = (params[:limit] || "100").to_i
    output = params[:output] || "html"
    empty_search = true

    sparql_exec = sparql
    if sparql_exec != "" && limit > 0
      sparql_exec += " limit #{limit}"
      empty_search = false
    end
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql_exec)

    if empty_search
      sparql = default_sparql()
    end
    presenter = SparqlPresenter.new(sparql, query, limit, output, empty_search)
  end

  def default_sparql()
    "SELECT ?s ?p ?o\nWHERE {\n  ?s ?p ?o .\n}"
  end
end
