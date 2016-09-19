require "./lib/sparql/query.rb"

class Faculty
  URI_FACULTY = "http://vivoweb.org/ontology/core#FacultyMember"
  URI_TITLE = "http://vivoweb.org/ontology/core#preferredTitle"
  URI_LABEL = "http://www.w3.org/2000/01/rdf-schema#label"
  URI_THUMBNAIL = "http://vitro.mannlib.cornell.edu/ns/vitro/public#mainImage"
  URI_THUMBNAIL_LOC = "http://vitro.mannlib.cornell.edu/ns/vitro/public#downloadLocation"
  URI_INDIVIDUAL = "http://vivo.brown.edu/individual"
  URI_EDUCATION_TRAINING = "http://vivoweb.org/ontology/core#educationalTraining"
  URI_TRAINING_ORG = "http://vivoweb.org/ontology/core#trainingAtOrganization"
  URI_DEGREE_DATE = "http://vivo.brown.edu/ontology/vivo-brown/degreeDate"
  URI_TEACHER_FOR = "http://vivo.brown.edu/ontology/vivo-brown/teacherFor"
  URI_HAS_COLLABORATOR = "http://vivoweb.org/ontology/core#hasCollaborator"
  URI_CONTRIBUTOR_TO = "http://vivo.brown.edu/ontology/citation#contributorTo"
  URI_CIT_VOLUME = "http://vivo.brown.edu/ontology/citation#volume"
  URI_CIT_ISSUE = "http://vivo.brown.edu/ontology/citation#issue"
  URI_CIT_DATE = "http://vivo.brown.edu/ontology/citation#date"
  URI_CIT_PAGES = "http://vivo.brown.edu/ontology/citation#pages"
  URI_CIT_AUTHOR_LIST = "http://vivo.brown.edu/ontology/citation#authorList"
  URI_CIT_PUB_IN = "http://vivo.brown.edu/ontology/citation#publishedIn"

  def self.all
    sparql = <<-END_SPARQL.gsub(/\n/, '')
      select distinct ?s ?label ?title ?image
      where {
        ?s ?p <#{URI_FACULTY}> .
        ?s <#{URI_LABEL}> ?label .
        ?s <#{URI_TITLE}> ?title .
        ?s <#{URI_THUMBNAIL}> ?thumbnail .
        ?thumbnail <#{URI_THUMBNAIL_LOC}> ?image .
      }
      limit 100
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      FacultyListItem.new(row[:s], row[:label], row[:title], row[:image])
    end
  end

  def self.get_one(id)
    sparql = <<-END_SPARQL.gsub(/\n/, '')
      select ?p ?o
      where
      {
        <#{URI_INDIVIDUAL}/#{id}> ?p ?o .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    faculty = query.to_object(FacultyItem)
    faculty.thumbnail = get_image(id)
    faculty.contributor_to = get_contributor_to(id)
    faculty.education = get_education(id)
    faculty.teacher_for = get_teacher_for(id)
    faculty.collaborators = get_collaborators(id)
    faculty
  end

  def self.get_image(id)
    sparql = <<-END_SPARQL.gsub(/\n/, '')
      select ?image
      where {
        <#{URI_INDIVIDUAL}/#{id}> <#{URI_THUMBNAIL}> ?thumbnail .
        ?thumbnail <#{URI_THUMBNAIL_LOC}> ?image .
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
    sparql = <<-END_SPARQL.gsub(/\n/, '')
      select ?school_uri ?date ?degree ?school_name
      where
      {
        <#{URI_INDIVIDUAL}/#{id}> <#{URI_EDUCATION_TRAINING}> ?t .
        ?t <#{URI_TRAINING_ORG}> ?school_uri .
        ?t <#{URI_DEGREE_DATE}> ?date .
        ?t <#{URI_LABEL}> ?degree .
        ?school_uri <#{URI_LABEL}> ?school_name .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      TrainingItem.new(row[:school_uri], row[:date], row[:degree], row[:school_name])
    end
  end

  def self.get_teacher_for(id)
    sparql = <<-END_SPARQL.gsub(/\n/, '')
      select ?class_name
      where
      {
        <#{URI_INDIVIDUAL}/#{id}> <#{URI_TEACHER_FOR}> ?t .
        ?t <#{URI_LABEL}> ?class_name .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map { |row| row[:class_name] }
  end

  def self.get_collaborators(id)
    sparql = <<-END_SPARQL.gsub(/\n/, '')
      select ?c ?label ?title
      where
      {
        <#{URI_INDIVIDUAL}/#{id}> <#{URI_HAS_COLLABORATOR}> ?c .
        ?c <#{URI_TITLE}> ?title .
        ?c <#{URI_LABEL}> ?label .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      CollaboratorItem.new(row[:c], row[:label], row[:title])
    end
  end

  def self.get_contributor_to(id)
    sparql = <<-END_SPARQL.gsub(/\n/, '')
      select ?c ?volume ?issue ?date ?pages ?authorList ?publishedIn ?title
      where {
         <#{URI_INDIVIDUAL}/#{id}> <#{URI_CONTRIBUTOR_TO}> ?c .
         ?c <#{URI_CIT_VOLUME}> ?volume .
         ?c <#{URI_CIT_ISSUE}> ?issue .
         ?c <#{URI_CIT_DATE}> ?date .
         ?c <#{URI_CIT_PAGES}> ?pages .
         ?c <#{URI_CIT_AUTHOR_LIST}> ?authorList .
         ?c <#{URI_CIT_PUB_IN}> ?publishedIn .
         ?c <#{URI_LABEL}> ?title .
       }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      ContributorToItem.new(row[:c], row[:authorList], row[:title])
    end
  end
end
