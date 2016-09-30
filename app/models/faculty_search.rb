require "./app/models/faculty.rb"
require "./lib/solr/solr.rb"
require "./lib/solr/search_results.rb"
class FacultySearch
  def initialize(solr_url)
    @solr = Solr::Solr.new(solr_url)
    @solr_response = nil
  end

  def search(search_term)
    search_term = "*" if search_term.empty?
    solr_response = @solr.search(search_term)
    results = Solr::SearchResults.new(solr_response)
    uris = results.solr_docs.map { |doc| (doc["uri"] || []).first }
    results.items = Faculty.get_batch(uris)
    results
  end
end
