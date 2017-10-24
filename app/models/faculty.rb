class Faculty
  def self.get_one(id)
    self.get_one_from_solr(id)
  end

  def self.get_one_from_solr(id)
    solr_url = ENV["SOLR_URL"]
    solr = SolrLite::Solr.new(solr_url)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
    return nil if solr_doc == nil

    solr_json = solr_doc["json_txt"].first
    hash = JsonUtils.safe_parse(solr_json)
    return nil if hash == nil

    images_url = ENV["IMAGES_URL"]
    thumbnail = solr_doc["thumbnail_file_path_s"]
    thumbnail_url = ModelUtils.thumbnail_url(thumbnail, images_url)
    if thumbnail != nil && thumbnail_url == nil
      Rails.logger.warn "Could not calculate thumbnail URL for #{thumbnail} (#{hash['id']})"
    end

    FacultyItem.from_hash(hash, thumbnail_url)
  end
end
