require "./app/models/json_utils.rb"
require "./app/models/organization_item.rb"
class Organization
  def self.get_one(id)
    self.get_one_from_solr(id)
  end

  def self.get_one_from_solr(id)
    solr_url = ENV["SOLR_URL"]
    solr = SolrLite::Solr.new(solr_url)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
    solr_json = solr_doc["json_txt"].first
    hash = JsonUtils.safe_parse(solr_json)
    return nil if hash == nil
    OrganizationItem.from_hash(hash)
  end
end
