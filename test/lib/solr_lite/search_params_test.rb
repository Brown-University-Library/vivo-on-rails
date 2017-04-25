require "minitest/autorun"
require "byebug"
require "./lib/solr_lite/search_params.rb"
class SearchParamsTest < Minitest::Test

  def default_facets
    facet_A = SolrLite::FacetField.new("fieldA", "Field A")
    facet_B = SolrLite::FacetField.new("fieldB", "Field B")
    [facet_A, facet_B]
  end

  def test_to_user_query_string
    # Search param defaults
    q = "hello"
    fq = []
    params = SolrLite::SearchParams.new(q, fq, default_facets())
    assert params.q = "hello"
    assert params.fq = []
    assert params.page == 1
    assert params.page_size == 20
    assert params.facet_for_field("fieldA") != nil
    assert params.facet_for_field("fieldB") != nil

    # From params to query string
    qs = params.to_user_query_string
    assert qs.include?("q=hello")

    # From query string to params
    params2 = SolrLite::SearchParams.from_query_string(qs, default_facets())
    assert params2.q == "hello"
    assert params2.page == 1
    assert params2.page_size == 20
    assert params2.facet_for_field("fieldA") != nil
    assert params2.facet_for_field("fieldB") != nil

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
    fq = [SolrLite::FilterQuery.from_query_string('F1|V1')]
    params = SolrLite::SearchParams.new(q, fq, default_facets())
    qs = params.to_solr_query_string()
    assert qs.include?("&q=hello")
    assert qs.include?("&rows=20")
    assert qs.include?("&start=0")
    assert qs.include?('&fq=F1:"V1"')

    # Make sure the facets are included
    assert qs.include?("&facet.field=fieldA")
    assert qs.include?("&facet.field=fieldB")
  end

  def test_to_solr_query_string_q_vs_fq
    # q and fq
    fq = [SolrLite::FilterQuery.from_query_string('F1|V1')]
    params = SolrLite::SearchParams.new("hello", fq)
    qs = params.to_solr_query_string
    assert qs.include?("&q=hello")
    assert qs.include?('&fq=F1:"V1"')

    # no q
    params = SolrLite::SearchParams.new("", fq)
    qs = params.to_solr_query_string
    assert !qs.include?("&q=")
    assert qs.include?('&fq=F1:"V1"')

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
