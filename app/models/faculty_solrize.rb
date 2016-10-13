require "./app/models/faculty.rb"
require "./lib/solr/solr.rb"
class FacultySolrize
  def initialize(solr_url)
    @solr_url = solr_url
  end

  def add_all()
    uris = Faculty.all_uris
    uris.each do |uri|
      id = uri.split("/").last
      add_one(id)
    end
  end

  def add_one(id)
    json = get_json(id)
    solr = Solr::Solr.new(@solr_url)
    solr.update(json)
  end

  def get_json(id)
    faculty = Faculty.get_one(id)
    JSON.pretty_generate(JSON.parse(faculty.to_json))
  end
end
