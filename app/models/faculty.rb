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
      f.item.has_coauthors = self.has_coauthors?(id)
    end
    f
  end

  def self.get_solr_doc(id)
    solr_url = ENV["SOLR_URL"]
    logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil
    solr = SolrLite::Solr.new(solr_url, logger)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
  end

  def self.has_coauthors?(id)
    coauthors = self.coauthors_cache()
    if coauthors != nil
      key = "http://vivo.brown.edu/individual/#{id}"
      if coauthors[key] != nil
        return true
      end
    end
    false
  end

  def self.coauthors_cache
    Rails.cache.fetch("coauthors_list", expires_in: 5.minute) do
      begin
        Rails.logger.info "Fetching coauthor list."
        ok, data = CoauthorGraph.get_list
        data
      rescue Exception => e
        Rails.logger.error "Could not cache coauthor list. #{e}"
        nil
      end
    end
  end

end
