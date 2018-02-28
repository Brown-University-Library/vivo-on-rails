class Organization
  attr_accessor :solr_doc, :json_txt, :item

  def self.load_from_solr(id)
    solr_doc = get_solr_doc(id)
    if solr_doc == nil
      return nil
    end

    o = Organization.new()
    o.solr_doc = solr_doc
    json_txt = solr_doc["json_txt"].first
    o.json_txt = JsonUtils.safe_parse(json_txt)
    if o.json_txt != nil
      images_url = ENV["IMAGES_URL"]
      # display_name = f.solr_doc["display_name_s"]
      thumbnail = o.solr_doc["thumbnail_file_path_s"]
      thumbnail_url = ModelUtils.thumbnail_url(thumbnail, images_url)
      if thumbnail != nil && thumbnail_url == nil
        Rails.logger.warn "Could not calculate thumbnail URL for #{thumbnail} (#{hash['id']})"
      end
      o.item = OrganizationItem.from_hash(o.json_txt, thumbnail_url)
    end
    o
  end

  def self.get_solr_doc(id)
    solr_url = ENV["SOLR_URL"]
    logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil
    solr = SolrLite::Solr.new(solr_url, logger)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
  end
end
