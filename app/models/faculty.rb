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
      if f.item.collaborators.count == 0
        f.item.has_collaborators = false
      else
        # Note: Due to the way the data is stored in the Data service
        # it is possible that we return true for individuals that have
        # an empty collaborator network. This should be very rare since
        # we are only making the call if the individual has explicitly
        # indicated collaborators on their profile.
        f.item.has_collaborators = self.has_collaborators?(id)
      end
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

  def self.has_collaborators?(id)
    collabs = self.collaborators_cache()
    if collabs != nil
      key = "http://vivo.brown.edu/individual/#{id}"
      if collabs[key] != nil
        return true
      end
    end
    false
  end

  def self.coauthors_cache()
    Rails.cache.fetch("coauthors_list", expires_in: 5.minute) do
      begin
        Rails.logger.info "Fetching coauthor list."
        ok, data = CoauthorGraph.get_list
        if ok
          data
        else
          Rails.logger.error "Could not cache coauthor list."
          nil
        end
      rescue Exception => e
        Rails.logger.error "Could not cache coauthor list. #{e}"
        nil
      end
    end
  end

  def self.collaborators_cache()
    Rails.cache.fetch("collaborators_list", expires_in: 5.minute) do
      begin
        Rails.logger.info "Fetching collaborators list."
        ok, data = CollabGraph.get_list
        if ok
          data
        else
          Rails.logger.error "Could not cache collaborators list."
          nil
        end
      rescue Exception => e
        Rails.logger.error "Could not cache collaborators list. #{e}"
        nil
      end
    end
  end
end
