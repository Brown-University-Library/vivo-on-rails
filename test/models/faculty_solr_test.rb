require "minitest/autorun"
require "byebug"
require "./app/models/faculty_solr.rb"

class FacultySolrTest < Minitest::Test
  def test_search
    solr_url = ENV["SOLR_URL"]
    solr = FacultySolr.new(solr_url)
    search_term = "bauer"
    results = solr.search(search_term)
    assert_equal 5, results.count
  end
end
