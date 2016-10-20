require "minitest/autorun"
require "byebug"
require "./app/models/faculty_search.rb"

class FacultySearchTest < Minitest::Test
  def test_faculty_search
    solr_url = ENV["SOLR_URL"]
    searcher = FacultySearch.new(solr_url)
    search_results = searcher.search("Bauer")
    assert_equal 5, search_results.items.count
    assert search_results.items.any? {|i| i.label == "Bauer, Cici"}
  end

  def test_organization_search
    solr_url = ENV["SOLR_URL"]
    searcher = FacultySearch.new(solr_url)
    search_results = searcher.search('"subject matter grounding in medicine"')
    assert search_results.items.count == 1
    assert search_results.items[0].name == "Biostatistics"
  end

  def test_facets
    solr_url = ENV["SOLR_URL"]
    searcher = FacultySearch.new(solr_url)
    search_results = searcher.search('medicine')
    facet = search_results.facets.find {|f|f.name = "record_type"}
    assert facet.value_count("ORGANIZATION") > 0
    assert facet.value_count("PEOPLE") > 0
  end

  def test_faculty_search
    solr_url = ENV["SOLR_URL"]
    searcher = FacultySearch.new(solr_url)
    search_results = searcher.search("Bauer")
    assert_equal 5, search_results.items.count
    assert search_results.items.any? {|i| i.label == "Bauer, Cici"}
  end
end
