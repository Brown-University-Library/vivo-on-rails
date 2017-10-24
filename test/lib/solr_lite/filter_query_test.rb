require "minitest/autorun"
require "byebug"
require "./lib/solr_lite/filter_query.rb"
class FilterQueryTest < Minitest::Test

  def test_encodings
    fq = SolrLite::FilterQuery.from_query_string('F1|V1 b&w')
    assert_equal "F1", fq.field
    assert_equal "V1 b&w", fq.value
    assert_equal "%28F1%3A%22V1+b%26w%22%29", fq.solr_value
    assert_equal "F1|V1+b%26w", fq.qs_value
    assert_equal "F1|V1 b&w", fq.form_value

    #
    # @field = field
    # @value = value
    # # Very important to escape the : otherwise URL.parse throws an error in Linux
    # @solr_value = CGI.escape(field + ':"' + value + '"')  # as needed by Solr
    # @qs_value = "#{field}|#{CGI.escape(value)}"           # URL friendly (no : or quotes)
    # @form_value = "#{field}|#{value}"                     # HTML Form friendly (no encoding, the form auto-encodes on POST)
    # @title = field                                        # default to field name
    # @remove_url = nil
    #
    # assert qs.include?("page=2")
  end
end
