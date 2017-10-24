# Handles fetching Faculty information from Fuseki via SPARQL queries.
#
# This class was used then we protyped populating a separate Solr index
# with data from VIVO rather than using the built-in Solr index that
# VIVO manages.
#
# We don't use this class anymore but I am keeping it since it has the SPARQL
# queries with the predicates that we need to fetch the data.
# This class should be removed after we go live.
#
require "./lib/sparql/query.rb"
require "./lib/solr_lite/solr.rb"
require "./app/models/json_utils.rb"
#require "./app/models/faculty_list_item.rb"
require "./app/models/faculty_item.rb"
require "./app/models/contributor_to_item.rb"
require "./app/models/education_item.rb"
require "./app/models/collaborator_item.rb"
require "./app/models/affiliation_item.rb"
require "./app/models/on_the_web_item.rb"
require "./app/models/training_item.rb"
require "./app/models/model_utils.rb"

class FacultyListItem
  attr_accessor :id, :uri, :name, :title, :thumbnail, :email

  def initialize(values = nil)
    ModelUtils.set_values_from_hash(self, values)
    @thumbnail = ModelUtils.safe_thumbnail(@thumbnail)
    @id = @uri
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end
end


class FacultyFuseki

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
    solr = SolrLite::Solr.new(solr_url)
    solr_doc = solr.get(CGI.escape("http://vivo.brown.edu/individual/#{id}"))
    return nil if solr_doc == nil
    solr_json = solr_doc["json_txt"].first
    hash = JsonUtils.safe_parse(solr_json)
    return nil if hash == nil
    FacultyItem.from_hash(hash)
  end

  def self.get_one_from_fuseki(id)
    sparql = <<-END_SPARQL
      select ?uri ?overview ?research_overview ?research_statement
        ?scholarly_work ?email ?org_label ?name ?title ?awards
        ?funded_research ?teaching_overview ?affiliations_text
        ?cv_link ?cv_link_text
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
          ?uri brown:cv ?cv .
          ?cv core:linkURI ?cv_link .
          ?cv core:linkAnchorText ?cv_link_text .
        }
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    result = query.results.first
    return nil if result == nil
    # TODO: How to handle if we get more than one
    faculty = FacultyItem.new(result)
    faculty.hidden = get_is_hidden?(id)
    faculty.thumbnail = get_image(id)
    faculty.contributor_to = get_contributor_to(id)
    faculty.education = get_education(id)
    faculty.teacher_for = get_teacher_for(id)
    faculty.collaborators = get_collaborators(id)
    faculty.affiliations = get_affiliations(id)
    faculty.research_areas = (get_research_areas(id) + get_geo_research_areas(id)).uniq
    faculty.on_the_web = get_on_the_web(id)
    faculty.appointments = get_appointments(id)
    faculty.credentials = get_credentials(id)
    faculty.training = get_training(id)
    faculty
  end

  def self.get_on_the_web(id)
    sparql = <<-END_SPARQL
      select ?uri ?rank ?url ?text
      where {
        individual:#{id} brown:drrbWebPage ?uri .
        ?uri core:linkURI ?url .
        optional { ?uri core:linkAnchorText ?text . }
        optional { ?uri core:rank ?rank . }
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    on_the_web = query.results.map { |row| OnTheWebItem.new(row) }
    on_the_web.sort_by { |x| x.rank }
  end

  def self.get_is_hidden?(id)
    sparql = <<-END_SPARQL
      select (count(*) as ?count)
      where {
        individual:#{id} a bdisplay:Hidden .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.first[:count].to_i > 0
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
      EducationItem.new(row)
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
        ?type ?doi ?venue_name ?pub_med_id
      where {
         individual:#{id} citation:contributorTo ?uri .
         ?uri citation:hasContributor individual:#{id} .
         optional { ?uri citation:volume ?volume . }
         optional { ?uri citation:issue ?issue . }
         optional { ?uri citation:date ?date . }
         optional { ?uri citation:pages ?pages . }
         optional { ?uri citation:authorList ?authors . }
         optional { ?uri citation:publishedIn ?published_in . }
         optional { ?uri rdfs:label ?title . }
         optional { ?uri vitro0_7:mostSpecificType ?type . }
         optional { ?uri citation:doi ?doi . }
         optional { ?uri citation:pmid ?pub_med_id .}
         optional {
           ?uri citation:hasVenue ?venue .
           ?venue rdfs:label ?venue_name .
         }
       }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    # TODO: figure out a better way to removing duplicates
    #       (see what VIVO does to pick the contribuition)
    uniq_contributions = query.results.uniq { |row| row[:uri] }
    uniq_contributions.map { |row| ContributorToItem.new(row) }
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
    uniq_affiliations = query.results.uniq { |row| row[:uri] }
    uniq_affiliations.map do |row|
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

  def self.get_geo_research_areas(id)
    sparql = <<-END_SPARQL
      select distinct ?name
      where
      {
        individual:#{id} brown:hasGeographicResearchArea ?a .
        ?a rdfs:label ?name .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map { |row| row[:name] }
  end


  def self.get_appointments(id)
    sparql = <<-END_SPARQL
    select ?uri ?name ?department ?org_name ?start_date ?end_date
    where {
      individual:#{id} profile:hasAppointment ?uri .
      ?uri rdfs:label ?name .
      ?uri profile:department ?department .
      ?uri profile:endDate ?end_date .
      ?uri profile:startDate ?start_date .
      optional {
        ?uri profile:hasOrganization ?org .
        ?org rdfs:label ?org_name .
      }
      optional {
        ?uri profile:hasHospital ?hospital .
        ?hospital rdfs:label ?org_name .
      }
    }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    appointments = query.results.map { |row| AppointmentItem.new(row) }
    appointments.sort_by { |x| x.start_date || DateTime.new }.reverse
  end

  def self.get_credentials(id)
    sparql = <<-END_SPARQL
    select ?uri ?start_date ?name ?end_date ?number ?grantor_name ?specialty_name
    where {
      individual:#{id} profile:hasCredential ?uri .
      ?uri profile:startDate ?start_date .
      ?uri rdfs:label ?name .
      optional { ?uri profile:endDate ?end_date . }
      optional { ?uri profile:credentialNumber ?number . }
      optional {
        ?uri profile:credentialGrantedBy ?grantor .
        ?grantor rdfs:label ?grantor_name
      }
      optional {
        ?uri profile:hasSpecialty ?specialty .
        ?specialty rdfs:label ?specialty_name
      }
    }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    credentials = query.results.map { |row| CredentialItem.new(row) }
    credentials.sort_by { |x| x.start_date || DateTime.new }.reverse
  end

  def self.get_training(id)
    sparql = <<-END_SPARQL
      select ?name ?start_date ?end_date ?city ?state ?country
        ?org_name ?hospital_name ?specialty_name
      where {
        individual:#{id} profile:hasTraining ?uri .
        ?uri rdfs:label ?name .
        optional { ?uri profile:city ?city . }
        optional { ?uri profile:state ?state . }
        optional { ?uri profile:country ?country . }
        optional { ?uri profile:startDate ?start_date . }
        optional { ?uri profile:endDate ?end_date . }
        optional {
          ?uri profile:hasOrganization ?org .
          ?org rdfs:label ?org_name .
        }
        optional {
          ?uri profile:hasHospital ?hospital .
          ?hospital rdfs:label ?hospital_name .
        }
        optional {
          ?uri profile:hasSpecialty ?specialty .
          ?specialty rdfs:label ?specialty_name .
        }
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    training = query.results.map { |row| TrainingItem.new(row) }
    training.sort_by { |x| x.start_date || DateTime.new }.reverse
  end
end