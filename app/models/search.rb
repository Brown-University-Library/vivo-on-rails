require "./app/models/json_utils.rb"
require "./app/models/search_item.rb"
require "./app/models/faculty.rb"
require "./lib/solr_lite/solr.rb"
require "./lib/solr_lite/search_results.rb"
class Search
  def initialize(solr_url)
    @solr = SolrLite::Solr.new(solr_url)
  end

  def search(params, extra_fqs)
    params.fl = ["id", "record_type", "json_txt"]
    results = @solr.search(params, extra_fqs)
    results.solr_docs.each do |doc|
      record_type = (doc["record_type"] || []).first
      case record_type
      when "ORGANIZATION"
        json = JsonUtils.safe_parse(doc["json_txt"].first)
        item = OrganizationItem.new(json)
        results.items << SearchItem.from_organization(item)
      when "PEOPLE"
        json = JsonUtils.safe_parse(doc["json_txt"].first)
        item = FacultyListItem.new(json)
        results.items << SearchItem.from_person(item)
      else
        # A VIVO type not supported on our new front-end.
        # TODO: we should either filter them our in our `q` parameter
        # so that they are not returned at all.
      end
    end
    results
  end
end
