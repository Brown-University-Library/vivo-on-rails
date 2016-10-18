require "./lib/sparql/query.rb"
require "./app/models/faculty_list_item.rb"
require "./app/models/faculty_item.rb"
require "./app/models/contributor_to_item.rb"
require "./app/models/training_item.rb"
require "./app/models/collaborator_item.rb"
require "./app/models/affiliation_item.rb"
class Faculty

  def self.all
    sparql = <<-END_SPARQL
      select distinct ?uri ?label ?title ?image
      where {
        ?uri ?p core:FacultyMember .
        ?uri rdfs:label ?label .
        ?uri core:preferredTitle ?title .
        ?uri vitro:mainImage ?thumbnail .
        optional { ?thumbnail vitro:downloadLocation ?image . }
      }
      limit 100
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
      limit 100
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
        select distinct ?uri ?label ?title ?image
        where {
          bind(<#{uri}> as ?uri) .
          ?uri ?p core:FacultyMember .
          ?uri rdfs:label ?label .
          optional { ?uri core:preferredTitle ?title . }
          optional {
            ?uri vitro:mainImage ?thumbnail .
            ?thumbnail vitro:downloadLocation ?image .
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

  def self.get_one(id)
    sparql = <<-END_SPARQL
      select ?uri ?overview ?research_overview ?research_statement
        ?scholarly_work ?email ?org_label ?label ?title ?awards
        ?funded_research ?teaching_overview ?affiliations_text
      where
      {
        bind(individual:#{id} as ?uri) .
        optional { ?uri core:overview ?overview . }
        optional { ?uri core:researchOverview ?research_overview . }
        optional { ?uri brown:researchStatement ?research_statement . }
        optional { ?uri brown:scholarlyWork ?scholarly_work . }
        optional { ?uri core:primaryEmail ?email . }
        optional { ?uri brown:primaryOrgLabel ?org_label . }
        optional { ?uri rdfs:label ?label . }
        optional { ?uri core:preferredTitle ?title . }
        optional { ?uri brown:awardsAndHonors ?awards . }
        optional { ?uri brown:fundedResearch ?funded_research . }
        optional { ?uri core:teachingOverview ?teaching_overview . }
        optional { ?uri brown:affiliations ?affiliations_text . }
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

  def self.get_value(s_uri, p_uri)
    sparql = "select ?o where { <#{s_uri}> <#{p_uri}> ?o . }"
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
      TrainingItem.new(row[:school_uri], row[:date], row[:degree], row[:school_name])
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
      select ?c ?label ?title
      where
      {
        individual:#{id} core:hasCollaborator ?c .
        ?c core:preferredTitle ?title .
        ?c rdfs:label ?label .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      CollaboratorItem.new(row[:c], row[:label], row[:title])
    end
  end

  def self.get_contributor_to(id)
    sparql = <<-END_SPARQL
      select ?c ?volume ?issue ?date ?pages ?authorList ?publishedIn ?title
      where {
         individual:#{id} citation:contributorTo ?c .
         ?c citation:hasContributor individual:#{id} .
         ?c citation:volume ?volume .
         ?c citation:issue ?issue .
         ?c citation:date ?date .
         ?c citation:pages ?pages .
         ?c citation:authorList ?authorList .
         ?c citation:publishedIn ?publishedIn .
         ?c rdfs:label ?title .
       }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    # TODO: figure out a better way to removing duplicates
    #       (see what VIVO does to pick the contribuition)
    uniq_contributions = query.results.uniq { |row| row[:c] }
    uniq_contributions.map do |row|
      ContributorToItem.new(row[:c], row[:authorList], row[:title],
        row[:volume], row[:issue], row[:date], row[:pages], row[:published_in])
    end
  end

  def self.get_affiliations(id)
    sparql = <<-END_SPARQL
      select ?a ?label
      where
      {
        individual:#{id} brown:hasAffiliation ?a .
        ?a rdfs:label ?label .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      AffiliationItem.new(row[:a], row[:label])
    end
  end
end
