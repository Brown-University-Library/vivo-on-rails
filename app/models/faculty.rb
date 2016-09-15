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
  URI_AWARDS_HONORS = "http://vivo.brown.edu/ontology/vivo-brown/awardsAndHonors"
  URI_TEACHER_FOR = "http://vivo.brown.edu/ontology/vivo-brown/teacherFor"

  def self.all
    sparql = <<-END_SPARQL.gsub(/\n/, '')
      select distinct ?s ?label ?title ?image ?awards
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
    faculty.education = get_education(id)
    faculty.teaching = get_teaching(id)
    faculty.awards = self.get_value("#{URI_INDIVIDUAL}/#{id}",URI_AWARDS_HONORS)
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

  def self.get_teaching(id)
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
end
