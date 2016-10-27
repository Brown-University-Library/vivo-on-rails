require "./app/models/faculty.rb"
require "./lib/solr/solr.rb"
require "./lib/solr/search_results.rb"
class Search
  def initialize(solr_url)
    @solr = Solr::Solr.new(solr_url)
  end

  def search(params)
    solr_response = @solr.search(params)
    params.fl = ["id", "record_type", "text"]
    results = Solr::SearchResults.new(solr_response)
    results.solr_docs.each do |doc|
      record_type = (doc["record_type"] || []).first
      case record_type
      when "ORGANIZATION"
        json = JSON.parse(doc["text"].first)
        item = OrganizationItem.new(json)
        results.items << item
      when "PEOPLE"
        json = JSON.parse(doc["text"].first)
        item = FacultyListItem.new(json)
        results.items << item
      else
        # WTF?
      end
    end
    results
  end
end
