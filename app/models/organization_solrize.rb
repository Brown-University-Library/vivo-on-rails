require "./app/models/organization.rb"
require "./lib/solr/solr.rb"
class OrganizationSolrize
  def initialize(solr_url)
    @solr_url = solr_url
    @solr = Solr::Solr.new(@solr_url)
    @format = "v2"
  end

  def add_all()
    uris = Organization.all_uris
    uris.each_with_index do |uri, i|
      id = uri.split("/").last
      json = get_json(id)
      @solr.update_fast(json)
      if ((i+1) % 100) == 0
        @solr.commit
        puts "...#{i+1}"
      end
    end
    @solr.commit()
  end

  def add_one(id)
    json = get_json(id)
    @solr.update(json)
  end

  def get_json(id)
    org = Organization.get_one_from_fuseki(id)
    if @format == "v1"
      # JSON for the PORO.
      JSON.pretty_generate(JSON.parse(org.to_json))
    else
      # JSON with a few fields.
      # Text has the JSON for PORO Faculty.
      solr_obj = {
        id: org.id,
        record_type: org.record_type,
        text: org.to_json}
      solr_obj.to_json
    end
  end
end
