require "./app/models/faculty.rb"
require "./lib/solr/solr.rb"
require "./lib/solr/search_results.rb"
class FacultySearch
  def initialize(solr_url)
    @solr = Solr::Solr.new(solr_url)
  end

  def search(params)
    solr_response = @solr.search(params)
    results = Solr::SearchResults.new(solr_response)

    faculty_uris = []
    org_uris = []
    results.solr_docs.each do |doc|
      record_type = (doc["record_type"] || []).first
      uri = (doc["uri"] || []).first
      case record_type
      when "ORGANIZATION"
        org_uris << uri
      when "PEOPLE"
        faculty_uris << uri
      else
        # WTF?
      end
    end

    # TODO: use a search result item class instead
    faculty_list = Faculty.get_batch(faculty_uris)
    org_list = Organization.get_batch(org_uris)
    results.items = faculty_list + org_list
    results
  end
end
