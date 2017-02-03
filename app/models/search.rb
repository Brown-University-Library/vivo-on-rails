require "./app/models/faculty.rb"
require "./lib/solr_lite/solr.rb"
require "./lib/solr_lite/search_results.rb"
class Search
  def initialize(solr_url)
    @solr = Solr::Solr.new(solr_url)
  end

  # TODO: consider using a search result item class
  # rather than mixing and matching Faculty/Org object
  def search(params)
    params.fl = ["id", "record_type", "json_txt"]
    results = @solr.search(params)
    results.solr_docs.each do |doc|
      record_type = (doc["record_type"] || []).first
      case record_type
      when "ORGANIZATION"
        json = JSON.parse(doc["json_txt"].first)
        item = OrganizationItem.new(json)
        results.items << item
      when "PEOPLE"
        json = JSON.parse(doc["json_txt"].first)
        item = FacultyListItem.new(json)
        results.items << item
      else
        # WTF?
      end
    end
    results
  end
end
