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

    # Remember to update collab_graph.rb to fetch data for these
    # client-side customized organizations since the server would
    # have calculated the collaboration network without using the
    # faculty manually added here.
    case
      # This used to be the Swearer Center but now we are using it for the
      # Community-Engaged Faculty directory created by the Swearer Center.
      when id == "org-brown-univ-dept148"
        faculty_ids = cblr_faculty_ids()
        o.item.add_custom_members(faculty_ids)
      # Cogut Institute for the Humanities
      when id == "org-brown-univ-dept124"
        faculty_ids = ["tcampt", "lgandhi", "pguyer", "alaird", "pszendy"]
        o.item.add_custom_members(faculty_ids)
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

  def self.load(id, load_thumbnails = false)
    team = Team.find_by_id(id, true)
    if team != nil
      return from_team(team)
    end
    return load_from_solr(id, load_thumbnails)
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
    org.item.faculty = []
    org.item.thumbnail = nil  # use the default organization image

    team.members.each do |faculty|
      member_info = {
          id: faculty.item.vivo_id,
          faculty_uri: faculty.item.id,
          label: faculty.item.display_name,
          general_position: "TBD",
          specific_position: faculty.item.title
      }
      org.item.people << OrganizationMemberItem.new(member_info)
      org.item.faculty << faculty
    end

    org
  end

  # Returns an array with all the faculty for this organization
  # Notice that it removes duplicates (and therefore removes the fact that
  # some faculty might hold more than one appointment in the department)
  # and does not preserve the titles of the people in the department.
  def faculty_list()
    # If we have loaded the faculty list, use it
    # (usually the case for teams)...
    if item.faculty.count > 0
      return item.faculty
    end

    # ...otherwise build it from the list of people (array of OrgMemberItem)
    # This is needed because we don't store the entire faculty info
    # for organizations in Solr.
    ids = item.people.map {|person| person.vivo_id}.uniq
    list = Faculty.load_from_solr_many(ids)
    list
  end

  def self.cblr_faculty_ids()
    faculty_ids = []

    solr_url = ENV["SOLR_URL"]
    logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil

    # Get the members for the Community-Based Learning and Research
    # by fetching faculty that work on certain specific research areas...
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
    research_areas << "community-based"
    fq = SolrLite::FilterQuery.new("research_areas", research_areas)

    results = solr.search(params, [fq], nil, nil, true)
    results.solr_docs.each do |doc|
      faculty_ids << ModelUtils::vivo_id(doc["id"])
    end

    # ...plus these specific faculty (regardless of their research areas)
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
    faculty_ids << "rcarter1"
    faculty_ids << "jnazaren"
    faculty_ids << "ugur"
    faculty_ids << "aremensn"
    faculty_ids << "maclark"
    faculty_ids << "cspearin"
    faculty_ids << "vzaminda"
    faculty_ids << "fhamlin"
    faculty_ids << "cbull"
    faculty_ids << "al16"
    faculty_ids << "cgonsher"
    faculty_ids << "ldicarlo"
    faculty_ids << "dasobel"
    faculty_ids << "jr17"
    faculty_ids << "rb63"
    faculty_ids << "sk"
    faculty_ids << "amy"
    faculty_ids << "dritchie"
    faculty_ids << "oprilipk"
    faculty_ids << "cbarron1"
    faculty_ids << "tachilli"
    faculty_ids << "pvivierm"
    faculty_ids << "mdstewar"
    faculty_ids << "triker"
    faculty_ids << "adulinke"
    faculty_ids << "jstrandb"
    faculty_ids << "tash1"
    faculty_ids << "anunn"
    faculty_ids << "lyapp"
    faculty_ids << "ehudehar"
    faculty_ids << "mbachcou"
    faculty_ids << "psobral"
    faculty_ids << "yhamilak"
    faculty_ids << "bbrockma"
    faculty_ids << "laasnyde"
    faculty_ids << "marnold"
    faculty_ids << "mblennon"
    #added 2022-09
    faculty_ids << "sfrickel"
    faculty_ids << "mhasting"
    faculty_ids << "jpalella"
    faculty_ids << "akeene"
    faculty_ids << "rpotvin"
    faculty_ids << "emuelle3"
    faculty_ids << "eqazilba"
    faculty_ids << "ssaad5"
    faculty_ids << "aabdurra"
    faculty_ids << "imontero"
    faculty_ids << "nschuhma"
    faculty_ids << "tkelly7"
    faculty_ids << "edwalker"
    faculty_ids << "atovar"

    faculty_ids.uniq
  end
end
