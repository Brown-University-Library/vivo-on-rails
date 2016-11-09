require "./lib/sparql/query.rb"
require "./lib/solr/solr.rb"
require "./app/models/faculty_list_item.rb"
require "./app/models/faculty_item.rb"
require "./app/models/contributor_to_item.rb"
require "./app/models/training_item.rb"
require "./app/models/collaborator_item.rb"
require "./app/models/affiliation_item.rb"
class Faculty

  MAX_ROW_LIMIT = "limit 10000"

  def self.all
    sparql = <<-END_SPARQL
      select distinct ?uri ?name ?title ?image
      where {
        ?uri ?p core:FacultyMember .
        ?uri rdfs:label ?name .
        ?uri core:preferredTitle ?title .
        ?uri vitro:mainImage ?thumbnail .
        optional { ?thumbnail vitro:downloadLocation ?image . }
      }
      #{MAX_ROW_LIMIT}
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      FacultyListItem.new(row)
    end
  end

  def self.all_uris
    sparql = <<-END_SPARQL
      select distinct ?uri
      where {
        ?uri rdf:type core:FacultyMember .
      }
      #{MAX_ROW_LIMIT}
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map { |faculty| faculty[:uri] }
  end

  def self.get_batch(uris)
    results = []
    uris.each do |uri|
      subject = "<#{uri}>"
      sparql = <<-END_SPARQL
        select distinct ?uri ?name ?title ?thumbnail
        where {
          bind(<#{uri}> as ?uri) .
          ?uri ?p core:FacultyMember .
          ?uri rdfs:label ?name .
          optional { ?uri core:preferredTitle ?title . }
          optional {
            ?uri vitro:mainImage ?image .
            ?image vitro:downloadLocation ?thumbnail .
          }
        }
      END_SPARQL
      fuseki_url = ENV["FUSEKI_URL"]
      query = Sparql::Query.new(fuseki_url, sparql)
      query.results.each do |row|
        results << FacultyListItem.new(row)
      end
    end
    results
  end

  def self.get_one(id, from_solr = true)
    if from_solr
      self.get_one_from_solr(id)
    else
      self.get_one_from_fuseki(id)
    end
  end

  def self.get_one_from_solr(id)
    solr_url = ENV["SOLR_URL"]
    solr = Solr::Solr.new(solr_url)
    solr_doc = solr.get("http://vivo.brown.edu/individual/#{id}")
    solr_json = solr_doc["json_txt"].first
    hash = JSON.parse(solr_json)
    FacultyItem.from_hash(hash)
  end

  def self.get_one_from_fuseki(id)
    sparql = <<-END_SPARQL
      select ?uri ?overview ?research_overview ?research_statement
        ?scholarly_work ?email ?org_label ?name ?title ?awards
        ?funded_research ?teaching_overview ?affiliations_text
        ?web_page_text ?web_page_uri
      where
      {
        bind(individual:#{id} as ?uri) .
        ?uri rdf:type core:FacultyMember .
        optional { ?uri core:overview ?overview . }
        optional { ?uri core:researchOverview ?research_overview . }
        optional { ?uri brown:researchStatement ?research_statement . }
        optional { ?uri brown:scholarlyWork ?scholarly_work . }
        optional { ?uri core:primaryEmail ?email . }
        optional { ?uri brown:primaryOrgLabel ?org_label . }
        optional { ?uri rdfs:label ?name . }
        optional { ?uri core:preferredTitle ?title . }
        optional { ?uri brown:awardsAndHonors ?awards . }
        optional { ?uri brown:fundedResearch ?funded_research . }
        optional { ?uri core:teachingOverview ?teaching_overview . }
        optional { ?uri brown:affiliations ?affiliations_text . }
        optional {
          ?uri brown:drrbWebPage ?web .
          ?web core:linkAnchorText ?web_page_text .
          ?web core:linkURI ?web_page_uri .
        }
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    result = query.results.first
    return nil if result == nil
    # TODO: How to handle if we get more than one
    faculty = FacultyItem.new(result)
    faculty.thumbnail = get_image(id)
    faculty.contributor_to = get_contributor_to(id)
    faculty.education = get_education(id)
    faculty.teacher_for = get_teacher_for(id)
    faculty.collaborators = get_collaborators(id)
    faculty.affiliations = get_affiliations(id)
    faculty.research_areas = get_research_areas(id)
    faculty
  end

  def self.get_image(id)
    sparql = <<-END_SPARQL
      select ?image
      where {
        individual:#{id} vitro:mainImage ?thumbnail .
        ?thumbnail vitro:downloadLocation ?image .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.to_value
  end

  def self.get_education(id)
    sparql = <<-END_SPARQL
      select ?school_uri ?date ?degree ?school_name
      where
      {
        individual:#{id} core:educationalTraining ?t .
        ?t core:trainingAtOrganization ?school_uri .
        ?t brown:degreeDate ?date .
        ?t rdfs:label ?degree .
        ?school_uri rdfs:label ?school_name .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      TrainingItem.new(row)
    end
  end

  def self.get_teacher_for(id)
    sparql = <<-END_SPARQL
      select ?class_name
      where
      {
        individual:#{id} brown:teacherFor ?t .
        ?t rdfs:label ?class_name .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map { |row| row[:class_name] }
  end

  def self.get_collaborators(id)
    sparql = <<-END_SPARQL
      select ?uri ?name ?title
      where
      {
        individual:#{id} core:hasCollaborator ?uri .
        ?uri core:preferredTitle ?title .
        ?uri rdfs:label ?name .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      CollaboratorItem.new(row)
    end
  end

  def self.get_contributor_to(id)
    sparql = <<-END_SPARQL
      select ?uri ?volume ?issue ?date ?pages ?authors ?published_in ?title
      where {
         individual:#{id} citation:contributorTo ?uri .
         ?uri citation:hasContributor individual:#{id} .
         ?uri citation:volume ?volume .
         ?uri citation:issue ?issue .
         ?uri citation:date ?date .
         ?uri citation:pages ?pages .
         ?uri citation:authorList ?authors .
         ?uri citation:publishedIn ?published_in .
         ?uri rdfs:label ?title .
       }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    # TODO: figure out a better way to removing duplicates
    #       (see what VIVO does to pick the contribuition)
    uniq_contributions = query.results.uniq { |row| row[:uri] }
    uniq_contributions.map do |row|
      ContributorToItem.new(row)
    end
  end

  def self.get_affiliations(id)
    sparql = <<-END_SPARQL
      select ?uri ?name
      where
      {
        individual:#{id} brown:hasAffiliation ?uri .
        ?uri rdfs:label ?name .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      AffiliationItem.new(row)
    end
  end

  def self.get_research_areas(id)
    sparql = <<-END_SPARQL
      select distinct ?name
      where
      {
        individual:#{id} core:hasResearchArea ?a .
        ?a rdfs:label ?name .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      row[:name]
    end
  end
end
