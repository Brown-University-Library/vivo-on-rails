class Faculty
  attr_accessor :solr_doc, :json_txt, :item

  def self.load_from_solr(id)
    solr_doc = get_solr_doc(id)
    if solr_doc == nil
      return nil
    end

    f = Faculty.new()
    f.solr_doc = solr_doc
    json_txt = solr_doc["json_txt"].first
    f.json_txt = JsonUtils.safe_parse(json_txt)
    if f.json_txt != nil
      images_url = ENV["IMAGES_URL"]
      display_name = f.solr_doc["display_name_s"]
      fis_updated = f.solr_doc["fis_updated_s"]
      profile_updated = f.solr_doc["profile_updated_s"]
      show_visualizations = f.solr_doc["show_visualizations_s"] == "true"
      thumbnail = f.solr_doc["thumbnail_file_path_s"]
      thumbnail_url = ModelUtils.thumbnail_url(thumbnail, images_url)
      if thumbnail != nil && thumbnail_url == nil
        Rails.logger.warn "Could not calculate thumbnail URL for #{thumbnail} (#{id})"
      end
      f.item = FacultyItem.from_hash(f.json_txt, display_name, thumbnail_url,
        fis_updated, profile_updated, show_visualizations)
    end
    f
  end

  def self.get_solr_doc(id)
    solr_url = ENV["SOLR_URL"]
    logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil
    solr = SolrLite::Solr.new(solr_url, logger)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
  end

  # Returns the thumbnail_url for a given faculty ID.
  #
  # This is used to fetch the thumbnails of faculty when loading the members
  # of an organization. The reason for this is because we don't store (yet)
  # in the Solr document for the organization the thumbnail URL for each
  # faculty that belongs to it.
  def self.thumbnail_url_for(id)
    cache_key = "thumbnail_url_#{id}"
    Rails.cache.fetch(cache_key, expires_in: 2.minute) do
      begin
        solr_doc = get_solr_doc(id)
        if solr_doc == nil
          return nil
        end
        images_url = ENV["IMAGES_URL"]
        thumbnail = solr_doc["thumbnail_file_path_s"]
        ModelUtils.thumbnail_url(thumbnail, images_url)
      rescue Exception => e
        Rails.logger.error "Could not calculate thumbnail for: #{id}"
        nil
      end
    end
  end
end
