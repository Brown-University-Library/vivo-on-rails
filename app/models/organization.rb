class Organization
  attr_accessor :solr_doc, :json_txt, :item

  def self.load_from_solr(id, load_thumbnails = false)
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
      thumbnail = o.solr_doc["thumbnail_file_path_s"]
      thumbnail_url = ModelUtils.thumbnail_url(thumbnail, images_url)
      if thumbnail != nil && thumbnail_url == nil
        Rails.logger.warn "Could not calculate thumbnail URL for #{thumbnail} (#{hash['id']})"
      end
      o.item = OrganizationItem.from_hash(o.json_txt, thumbnail_url)
    end

    if id == "org-brown-univ-dept148"
      o.item.name = "Community-Engaged Faculty"
      o.item.overview = <<~OVERVIEW
      The Swearer Center is a hub of community, scholarship, and
      action at Brown University, connecting faculty, students,
      and staff with people and organizations across Rhode Island
      and around the globe to co-create knowledge and positive
      social change.<br/><br/>
      This directory, created by the Swearer Center
      in collaboration with Researchers@Brown,
      includes the profiles of faculty teaching CBLR-designated
      courses as well as those whose research areas include relevant
      terms (e.g., engaged scholarship, community engagement).<br/><br/>
      We recognize that not all faculty included here have a direct
      affiliation with the Swearer Center and that not all
      community-engaged faculty on campus are represented within
      these parameters. With any questions or comments about this
      page, please email <a href="mailto:julie_plaut@brown.edu">julie_plaut@brown.edu</a>.
      OVERVIEW
      members = swearer_center_members()
      members.each do |member|
        o.item.people << OrganizationMemberItem.new(member)
      end
    end

    # Set the picture of each member
    # (we could remove this once we have the thumbnail stored in Solr)
    if load_thumbnails
      member_ids = o.item.people.map { |f| f.vivo_id }
      faculties = Faculty.load_from_solr_many(member_ids)
      o.item.people.each do |member|
        faculty = faculties.find {|x| x.item.vivo_id == member.vivo_id }
        if faculty != nil
          member.thumbnail_url = faculty.item.thumbnail
        end
      end
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

  def self.swearer_center_members()
    solr_url = ENV["SOLR_URL"]
    logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil

    # Get the members for the Swearer Center by fetching faculty that
    # work on certain specific research areas.
    solr = SolrLite::Solr.new(solr_url, logger)
    params = params = SolrLite::SearchParams.new()
    params.q = "*"
    research_areas = []
    research_areas << "community engagement"
    research_areas << "engaged scholarship"
    research_areas << "engaged teaching"
    research_areas << "engaged research"
    research_areas << "community-based participatory research"
    research_areas << "community-based learning and research"
    research_areas << "public service"
    research_areas << "civic engagement"
    research_areas << "service learning"
    research_areas << "public scholarship"
    research_areas << "publicly engaged scholarship"
    research_areas << "scholarship of engagement"
    research_areas << "community-based scholarship"
    research_areas << "broader impact"

    fq = SolrLite::FilterQuery.new("research_areas", research_areas)
    results = solr.search(params, [fq], nil, nil, true)

    members = []
    results.solr_docs.each do |doc|
      member_info = {
        id: ModelUtils::vivo_id(doc["id"]),
        faculty_uri: doc["id"],
        label: doc["name_t"].first,
        general_position: "general position",
        specific_position: doc["title_t"].first
      }
      members << member_info
    end

    # Also add the following faculty regardless of their research areas
    faculty_ids = []
    faculty_ids << "iglasser"
    faculty_ids << "llapierr"
    faculty_ids << "rkcampbe"
    faculty_ids << "yy37"
    faculty_ids << "kschapir"
    faculty_ids << "dmk3"
    faculty_ids << "njacobs"
    faculty_ids << "vkrause"
    faculty_ids << "esikelia"
    faculty_ids << "mdkenned"
    faculty_docs = Faculty.load_from_solr_many(faculty_ids)
    faculty_docs.each do |faculty|

      # Skip this record if we already have it as a member
      next if members.find {|x| x[:faculty_uri] == faculty.item.id }

      member_info = {
        id: ModelUtils::vivo_id(faculty.item.id),
        faculty_uri: faculty.item.id,
        label: faculty.item.name,
        general_position: "general position",
        specific_position: faculty.item.title
      }
      members << member_info
    end

    members.sort_by {|x| x[:label]}
  end
end
