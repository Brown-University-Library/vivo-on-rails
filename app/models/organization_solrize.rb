require "./app/models/organization.rb"
require "./lib/solr/solr.rb"
class OrganizationSolrize
  def initialize(solr_url)
    @solr_url = solr_url
  end

  def add_all()
    uris = Organization.all_uris
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
    org = Organization.get_one(id)
    JSON.pretty_generate(JSON.parse(org.to_json))
  end
end
