require "./app/models/organization.rb"
require "./lib/solr_lite/solr.rb"
class OrganizationSolrize
  def initialize(solr_url)
    @solr_url = solr_url
    @solr = Solr::Solr.new(@solr_url)
  end

  def add_all()
    uris = Organization.all_uris
    Rails.logger.info("Processing #{uris.count} organization records...")
    uris.each_with_index do |uri, i|
      id = uri.split("/").last
      add_one(id, false)
      commit_batch(i+1)
    end
    commit()
    Rails.logger.info("Done Solrizing organization records.")
  end

  def add_one(id, commit = true)
    json = get_json(id)
    if json == nil
      Rails.logger.warn("ID #{id} was not found in Fuseki")
      return
    end
    solr_response = @solr.update(json, commit)
    if solr_response.ok?
      Rails.logger.info("...saved #{id}")
    else
      Rails.logger.warn("...error on #{id}: #{solr_response.error_msg}")
    end
  end

  def get_json(id)
    org = Organization.get_one_from_fuseki(id)
    return if org == nil
    solr_obj = {
      id: org.id,
      record_type: org.record_type,
      json_txt: org.to_json }
    solr_obj.to_json
  end

  private
    def commit_batch(i)
      if (i % 100) == 0
        commit()
      end
    end

    def commit()
      solr_response = @solr.commit()
      if !solr_response.ok?
        Rails.logger.warn("...error on comit: #{solr_response.error_msg}")
      end
    end
end
