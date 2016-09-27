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

  def self.faculty_one(uri, depth_limit = 3)
    triples = []
    subjects = []
    depth = 1
    faculty_one_recursive(uri, subjects, triples, depth, depth_limit)
    triples
  end

  def self.faculty_one_recursive(uri, subjects, triples, depth, depth_limit)
    if depth > depth_limit
      # puts "== bailing out at level #{depth_limit} =="
      return
    end
    sparql = <<-END_SPARQL
      select ?p ?o
      where {
        <#{uri}> ?p ?o .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    subjects << uri
    raw = query.raw_results
    raw.each do |row|
      predicate = row["p"]["value"]
      value = row["o"]["value"]
      is_object_uri = row["o"]["type"] == "uri"
      if is_object_uri
        triple_value = "<" + value + ">"
      else
        triple_value = '"' + clean(value) + '"'
      end

      triples << "<#{uri}> <#{predicate}> #{triple_value}"

      if is_object_uri
        object_uri = value
        if subjects.include?(object_uri)
          # nothing to do, we already visited this node
        else
          # visit the node recursively
          faculty_one_recursive(object_uri, subjects, triples, depth + 1, depth_limit)
        end
      end
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
