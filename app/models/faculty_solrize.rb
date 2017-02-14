require "./app/models/faculty.rb"
require "./lib/solr_lite/solr.rb"
class FacultySolrize
  def initialize(solr_url)
    @solr_url = solr_url
    @solr = SolrLite::Solr.new(@solr_url)
  end

  def add_all()
    uris = Faculty.all_uris
    Rails.logger.info("Processing #{uris.count} faculty records...")
    uris.each_with_index do |uri, i|
      id = uri.split("/").last
      add_one(id, false)
      commit_batch(i+1)
    end
    commit()
    Rails.logger.info("Done Solrizing faculty records.")
  end

  def add_new()
    uris = Faculty.all_uris
    Rails.logger.info("Processing #{uris.count} faculty records...")
    uris.each_with_index do |uri, i|
      if already_in_solr?(uri)
        Rails.logger.info("...skipped (#{i+1})#{uri}")
      else
        id = uri.split("/").last
        add_one(id, false)
        commit_batch(i+1)
      end
    end
    commit()
    Rails.logger.info("Done Solrizing faculty records.")
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
    faculty = Faculty.get_one_from_fuseki(id)
    return if faculty == nil
    solr_obj = {
      id: faculty.id,
      record_type: faculty.record_type,
      affiliations: faculty.affiliations.map { |a| a.name},
      research_areas: faculty.research_areas,
      json_txt: faculty.to_json }
    solr_obj.to_json
  end

  private
    def already_in_solr?(uri)
      solr_doc = @solr.get(uri)
      solr_doc != nil
    end

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
