require "./app/models/export.rb"
namespace :vivo do
  desc "Export a list of all faculty members"
  task :export_all do
    count = 100
    triples = Export.faculty(count)
    text = triples.join()
    File.write('./all.ttl', text)
  end

  task :export_one do
    # id = "jhogansc"
    id = "gpalomak"
    uri = "http://vivo.brown.edu/individual/#{id}"
    triples = Export.faculty_one(uri)
    text = triples.join()
    File.write("./#{id}.ttl", text)
  end
end
