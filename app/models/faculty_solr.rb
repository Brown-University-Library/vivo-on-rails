require "./app/models/faculty.rb"
require "./lib/solr/solr.rb"
class FacultySolr
  def initialize(solr_url)
    @solr_url = solr_url
  end

  def search(search_term)
    solr = Solr::Solr.new(@solr_url)
    solr_response = solr.search(search_term)
    docs = solr_response["response"]["docs"]
    ids = []
    docs.each do |doc|
      if doc["uri"].count > 0
        uri = doc["uri"].first
        ids << uri.split("/").last
      end
    end
    ids.map { |id| Faculty.get_one(id) }
  end

  def add_all()
    uris = Faculty.all_uris
    uris.each do |uri|
      id = uri.split("/").last
      add_one(id)
    end
  end

  def add_one(id)
    faculty = Faculty.get_one(id)
    json = JSON.pretty_generate(JSON.parse(faculty.to_json))
    solr = Solr::Solr.new(@solr_url)
    solr.update(json)
  end
end
