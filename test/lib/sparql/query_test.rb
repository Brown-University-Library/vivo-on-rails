require "minitest/autorun"
require "byebug"
require "./lib/sparql/query.rb"
class QueryTest < Minitest::Test
  def test_no_errors
    fuseki_url = ENV["FUSEKI_URL"]
    sparql = "select ?s where { ?s <nothing> <nothing> .} limit 0"
    query = Sparql::Query.new(fuseki_url, sparql)
    # we only care that it parsed correctly (e.g. it didn't blow up)
    assert_equal 0, query.results.count
  end
end
