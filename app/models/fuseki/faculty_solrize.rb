# Handles populating Solr with Faculty information.
#
# This class was used then we protyped populating a separate Solr index
# with data from VIVO rather than using the built-in Solr index that
# VIVO manages.
#
# We don't use this class anymore.
# This class should be removed after we go live.
#
require "./app/models/faculty.rb"
# require "./lib/solr_lite/solr.rb"
class FacultySolrize
  def initialize(solr_url)
    @solr_url = solr_url
    @solr = SolrLite::Solr.new(@solr_url)
  end

  def add_all()
    uris = Faculty.all_uris
    Rails.logger.info("Processing #{uris.count} faculty records...")
    batch = []
    uris.each_with_index do |uri, i|
      id = uri.split("/").last
      faculty = get_one(id)
      next if faculty == nil
      batch << faculty
      if save_batch(batch)
        batch = []
      end
    end
    save_batch(batch, true)
    Rails.logger.info("Done Solrizing faculty records.")
  end

  def add_one(id)
    result = false
    if id == nil
      Rails.logger.warn("No ID was provided")
    else
      faculty = get_one(id)
      if faculty != nil
        result = save_batch([faculty], true)
      end
    end
    result
  end

  def get_one(id)
    begin
      faculty = Faculty.get_one_from_fuseki(id)
      return if faculty == nil
      solr_obj = {
        id: faculty.id,
        name_t: faculty.name,
        title_t: faculty.title,
        department_t: faculty.org_label,
        overview_t: faculty.overview,
        email_s: faculty.email,
        short_id_s: faculty.id.split("/").last,
        record_type: faculty.record_type,
        affiliations: faculty.affiliations.map { |a| a.name }.uniq,
        research_areas: faculty.research_areas,
        published_in: faculty.published_in,
        appointment_at: faculty.appointments.map { |a| a.org_name }.uniq,
        alumni_of: faculty.education.map { |a| a.school_name }.uniq,
        hidden_b: faculty.hidden,
        json_txt: faculty.to_json
      }
    rescue => e
      solr_obj = nil
      Rails.logger.warn("Could not fetch faculty (#{id}). Error: #{e.message} at #{e.backtrace}")
    end
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
