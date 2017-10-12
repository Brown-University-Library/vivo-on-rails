# Handles populating Solr with Organization information.
#
# This class was used then we protyped populating a separate Solr index
# with data from VIVO rather than using the built-in Solr index that
# VIVO manages.
#
# We don't use this class anymore.
# This class should be removed after we go live.
#
require "./app/models/organization.rb"
require "./lib/solr_lite/solr.rb"
class OrganizationSolrize
  def initialize(solr_url)
    @solr_url = solr_url
    @solr = SolrLite::Solr.new(@solr_url)
  end

  def add_all()
    uris = Organization.all_uris
    Rails.logger.info("Processing #{uris.count} organization records...")
    batch = []
    uris.each_with_index do |uri, i|
      id = uri.split("/").last
      org = get_one(id)
      next if org == nil
      batch << org
      if save_batch(batch)
        batch = []
      end
    end
    save_batch(batch, true)
    Rails.logger.info("Done Solrizing organization records.")
  end

  def add_one(id)
    org = get_one(id)
    if org == nil
      Rails.logger.warn("ID #{id} was not found in Fuseki")
      return
    end
    save_batch([org], true)
  end

  def get_one(id)
    org = Organization.get_one_from_fuseki(id)
    return nil if org == nil
    solr_obj = {
      id: org.id,
      record_type: org.record_type,
      hidden_b: false,
      json_txt: org.to_json
    }
    solr_obj
  end

  private

    def save_batch(batch, force = false)
      return false if batch.count == 0
      if force || (batch.count % 100) == 0
        solr_response = @solr.update(batch.to_json)
        if solr_response.ok?
          Rails.logger.info("...saved #{batch.count} documents to Solr")
        else
          Rails.logger.warn("...error saving batch to Solr: #{solr_response.error_msg}")
        end
        return true
      end
      return false
    end
end
