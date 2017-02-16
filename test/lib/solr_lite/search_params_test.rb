require "minitest/autorun"
require "byebug"
require "./lib/solr_lite/search_params.rb"
class SearchParamsTest < Minitest::Test
  def test_to_user_query_string
    # Search param defaults
    q = "hello"
    fq = []
    facets = ["fieldA", "fieldB"]
    params = SolrLite::SearchParams.new(q, fq, facets)
    assert params.q = "hello"
    assert params.fq = []
    assert params.page == 1
    assert params.page_size == 20
    assert params.facets.include?("fieldA")
    assert params.facets.include?("fieldB")

    # From params to query string
    qs = params.to_user_query_string
    assert qs.include?("q=hello")

    # From query string to params
    params2 = SolrLite::SearchParams.from_query_string(qs, facets)
    assert params2.q == "hello"
    assert params2.page == 1
    assert params2.page_size == 20
    assert params2.facets.include?("fieldA")
    assert params2.facets.include?("fieldB")

    # With different page size and page numbers
    params2.page = 2
    params2.page_size = 3
    qs = params2.to_user_query_string
    assert qs.include?("q=hello")
    assert qs.include?("rows=3")
    assert qs.include?("page=2")
  end

  def test_to_solr_query_string
    q = "hello"
    fq = ["F1:V1"]
    facets = ["fieldA", "fieldB"]
    params = SolrLite::SearchParams.new(q, fq, facets)
    qs = params.to_solr_query_string
    assert qs.include?("&q=hello")
    assert qs.include?("&rows=20")
    assert qs.include?("&start=0")
    assert qs.include?("&fq=F1:V1")

    # Make sure the facets are included
    assert qs.include?("&facet.field=fieldA")
    assert qs.include?("&facet.field=fieldB")
  end

  def test_to_solr_query_string_q_vs_fq
    # q and fq no q
    params = SolrLite::SearchParams.new("hello", ["F1:V1"])
    qs = params.to_solr_query_string
    assert qs.include?("&q=hello")
    assert qs.include?("&fq=F1:V1")

    # no q
    params = SolrLite::SearchParams.new("", ["F1:V1"])
    qs = params.to_solr_query_string
    assert !qs.include?("&q=")
    assert qs.include?("&fq=F1:V1")

    # no fq
    params = SolrLite::SearchParams.new("hello")
    qs = params.to_solr_query_string
    assert qs.include?("&q=hello")
    assert !qs.include?("&fq=")

    # neither q not fq
    params = SolrLite::SearchParams.new()
    qs = params.to_solr_query_string
    assert !qs.include?("&q=")
    assert !qs.include?("&fq=")
  end
end
