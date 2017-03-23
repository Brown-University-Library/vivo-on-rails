require "./app/models/faculty.rb"
require "./lib/solr_lite/solr.rb"
require "./lib/solr_lite/search_results.rb"
class Search
  def initialize(solr_url)
    @solr = SolrLite::Solr.new(solr_url)
  end

  def search(params)
    params.fl = ["id", "record_type", "json_txt"]
    results = @solr.search(params)
    results.solr_docs.each do |doc|
      record_type = (doc["record_type"] || []).first
      case record_type
      when "ORGANIZATION"
        json = JSON.parse(doc["json_txt"].first)
        item = OrganizationItem.new(json)
        results.items << SearchItem.from_organization(item)
      when "PEOPLE"
        json = JSON.parse(doc["json_txt"].first)
        item = FacultyListItem.new(json)
        results.items << SearchItem.from_person(item)
      else
        # WTF?
      end
    end
    results
  end
end
