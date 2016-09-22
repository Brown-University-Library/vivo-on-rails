require "./lib/sparql/query.rb"
class Export
  URI_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  URI_FACULTY = "http://vivoweb.org/ontology/core#FacultyMember"

  def self.faculty(count=10)
    uris = self.faculty_uris(count)
    triples = []
    uris.each do |uri|
      faculty = faculty_one(uri)
      triples << faculty.flat_map {|i| i}
    end
    triples
  end

  def self.faculty_one(uri)
    sparql = <<-END_SPARQL
      select ?p ?o
      where {
        <#{uri}> ?p ?o .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    triples = []
    query.results.map do |row|
      if row[:o].start_with?("http://")
        # assumme is a URI
        value = "<" + row[:o] + ">"
      else
        # assumme is a literal
        value = '"' + clean(row[:o]) + '"'
      end
      triple = "<#{uri}> <#{row[:p]}> #{value} .\n"
      triples << triple
    end
    triples
  end

  def self.faculty_uris(count)
    sparql = <<-END_SPARQL
      select ?s
      where {
        ?s <#{URI_TYPE}> <#{URI_FACULTY}> .
      }
      limit #{count}
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map { |row| row[:s] }
  end

  def self.clean(value)
    # HORRIBLE HACK
    # clean the value so that we can export/import some test
    # data between Fuseki instances.
    value.gsub("\r",' ').gsub("\n",' ').gsub("\\", ' ').gsub('"', '\"')
  end
end
