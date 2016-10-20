require "./lib/sparql/query.rb"
class Export
  URI_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  URI_FACULTY = "http://vivoweb.org/ontology/core#FacultyMember"

  def self.faculty_all(file_name)
    puts "Fetching uris..."
    uris = Faculty.all_uris
    file = File.new(file_name, "w")
    puts "Exporting triples for #{uris.count} uris..."
    uris.each_with_index do |uri, i|
      triples = faculty_one(uri)
      puts "\t#{i+1}/#{uris.count}\t#{uri.split('/').last} (#{triples.count})"
      text = triples.join(" . \n") + " . \n"
      file.write(text)
    end
    file.close()
    puts "Done"
  end

  # def self.faculty_all()
  #   triples = []
  #   Faculty.all_uris.each do |uri|
  #     faculty = faculty_one(uri)
  #     triples << faculty.flat_map {|i| i}
  #   end
  #   triples
  # end

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

  def self.clean(value)
    # HORRIBLE HACK
    # clean the value so that we can export/import some test
    # data between Fuseki instances.
    value.gsub("\r",' ').gsub("\n",' ').gsub("\\", ' ').gsub('"', '\"')
  end
end
