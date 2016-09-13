require "./lib/sparql/query.rb"
class Faculty
  URI_FACULTY = "http://vivoweb.org/ontology/core#FacultyMember"
  URI_TITLE = "http://vivoweb.org/ontology/core#preferredTitle"
  URI_LABEL = "http://www.w3.org/2000/01/rdf-schema#label"
  URI_THUMBNAIL = "http://vitro.mannlib.cornell.edu/ns/vitro/public#mainImage"
  URI_THUMBNAIL_LOC = "http://vitro.mannlib.cornell.edu/ns/vitro/public#downloadLocation"
  URI_INDIVIDUAL = "http://vivo.brown.edu/individual"

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
end
