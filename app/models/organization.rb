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

  def self.load(id)
    team = Team.find_by_id(id)
    if team != nil
      return from_team(team)
    end
    return load_from_solr(id)
  end

  def self.from_team(team)
    org = Organization.new()
    org.item = OrganizationItem.new({})
    org.item.record_type = "TEAM"
    org.item.uri = "http://vivo.brown.edu/individual/#{team.id}"
    org.item.id = team.id
    org.item.name = team.name
    org.item.overview = team.name
    org.item.people = []

    team.member_ids.each do |id|
        member_info = {
            id: id,
            faculty_uri: "http://vivo.brown.edu/individual/#{id}",
            label: id,
            general_position: "general position",
            specific_position: "specific position"
        }
        member = OrganizationMemberItem.new(member_info)
        org.item.people << member
    end

    org
  end

  # Returns an array with all the faculty for this organization
  # Notice that it removes duplicates (and therefore removes the fact that
  # some faculty might hold more than one appointment in the department)
  # and does not preserve the titles of the people in the department.
  def faculty_list()
    ids = item.people.map {|person| person.vivo_id}.uniq
    list = Faculty.load_from_solr_many(ids)
    list
  end
end
