require "./app/models/export.rb"
namespace :vivo do
  desc "Export information about some faculty members"
  task :export_some do
    file = File.new("./some.ttl", "w")
    count = 100 # randomly pick the first N
    uris = Export.faculty_uris(count)
    uris.each do |uri|
      triples = Export.faculty_one(uri)
      puts "Wrote #{triples.count} triples for #{uri}"
      text = triples.join(" . \n") + " . \n"
      file.write(text)
    end
    file.close()
  end

  task :export_one do
    # id = "jhogansc"
    id = "gpalomak"
    uri = "http://vivo.brown.edu/individual/#{id}"
    triples = Export.faculty_one(uri)
    text = triples.join(" . \n") + " . \n"
    File.write("./#{id}.ttl", text)
  end
end
