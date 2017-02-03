require "minitest/autorun"
require "byebug"
require "./app/models/search.rb"
require "./lib/solr_lite/search_params.rb"

class SearchTest < Minitest::Test
  def test_faculty_search
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url)
    params = Solr::SearchParams.new("Bauer")
    search_results = searcher.search(params)
    assert_equal 5, search_results.items.count
    assert search_results.items.any? {|i| i.name == "Bauer, Cici"}
  end

  def test_organization_search
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url)
    params = Solr::SearchParams.new('"subject matter grounding in medicine"')
    search_results = searcher.search(params)
    assert search_results.items.count == 1
    assert search_results.items[0].name == "Biostatistics"
  end

  def test_facets
    facets = ["record_type", "affiliations.name"]
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url)
    params = Solr::SearchParams.new("medicine", [], facets)
    search_results = searcher.search(params)
    facet = search_results.facets.find {|f|f.name = "record_type"}
    assert facet.value_count("ORGANIZATION") > 0
    assert facet.value_count("PEOPLE") > 0
  end

  def test_pagination
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url)
    custom_page_size = 3

    # run a first search (with a custom page size)
    params = Solr::SearchParams.new("medicine")
    params.page_size = custom_page_size
    search_results = searcher.search(params)
    total_matches = search_results.num_found
    assert search_results.page == 1
    assert search_results.page_size == custom_page_size

    # go to the next page
    params.page += 1
    search_results = searcher.search(params)
    assert search_results.page == 2
    assert search_results.start == custom_page_size
    assert search_results.num_found == total_matches
  end

  def test_faculty_search
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url)
    params = Solr::SearchParams.new("Bauer")
    search_results = searcher.search(params)
    assert search_results.items.count > 4
    assert search_results.items.any? {|i| i.name == "Bauer, Cici"}
  end
end
