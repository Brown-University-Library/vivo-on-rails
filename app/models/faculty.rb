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
      thumbnail = f.solr_doc["thumbnail_file_path_s"]
      thumbnail_url = ModelUtils.thumbnail_url(thumbnail, images_url)
      if thumbnail != nil && thumbnail_url == nil
        Rails.logger.warn "Could not calculate thumbnail URL for #{thumbnail} (#{id})"
      end
      f.item = FacultyItem.from_hash(f.json_txt, display_name, thumbnail_url,
        fis_updated, profile_updated)
    end
    f
  end

  def self.get_solr_doc(id)
    solr_url = ENV["SOLR_URL"]
    logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil
    solr = SolrLite::Solr.new(solr_url, logger)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
  end
end
