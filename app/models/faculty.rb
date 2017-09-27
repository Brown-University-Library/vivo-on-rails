class Faculty
  def self.get_one(id, from_solr = true)
    if from_solr
      self.get_one_from_solr(id)
    else
      get_one_from_fuseki.get_one_from_fuseki(id)
    end
  end

  def self.get_one_from_solr(id)
    solr_url = ENV["SOLR_URL"]
    solr = SolrLite::Solr.new(solr_url)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
    return nil if solr_doc == nil
    solr_json = solr_doc["json_txt"].first
    hash = JsonUtils.safe_parse(solr_json)
    return nil if hash == nil
    FacultyItem.from_hash(hash)
  end
end
