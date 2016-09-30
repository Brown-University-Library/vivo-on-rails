require "minitest/autorun"
require "byebug"
require "./app/models/faculty_search.rb"

class FacultySearchTest < Minitest::Test
  def test_search
    solr_url = ENV["SOLR_URL"]
    searcher = FacultySearch.new(solr_url)
    search_results = searcher.search("bauer")
    assert_equal 5, search_results.items.count
  end
end
