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

  def self.for_team(id)
    # For now we only recognize one team
    if id != "team-crisp"
      return nil
    end
    o = Organization.new()
    o.item = OrganizationItem.new({})
    o.item.record_type = "TEAM"
    o.item.uri = "http://vivo.brown.edu/individual/#{id}"
    o.item.id = id
    o.item.name = "Consortium for Research and Innovation in Suicide Prevention"
    o.item.overview = "Consortium for Research and Innovation in Suicide Prevention"
    o.item.people = []

    ids = ["sarias1", "ma1", "jbarredo", "lbrick", "ac67", "echen13", "ddickste",
    "yduartev", "mjfrank", "bgaudian", "rnjones", "kkemp",
    "rl11", "bm8", "imilleri", "nnugent", "jprimack", "mranney",
    "hschatte", "aspirito", "luebelac", "lweinsto", "jw33", "syenphd"]
    ids.each do |id|
        member_info = {
            id: id,
            faculty_uri: "http://vivo.brown.edu/individual/#{id}",
            label: id,
            general_position: "general position",
            specific_position: "specific position"
        }
        member = OrganizationMemberItem.new(member_info)
        o.item.people << member
    end

    o
  end
end
