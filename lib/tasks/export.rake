# These tasks are used to export data from our live Fuseki
# endpoint to files that we can import in our test environments.
require "./app/models/export.rb"
namespace :vivo do
  desc "Export information about all faculty members"
  task :export_all do
    Export.faculty_all("./all.ttl")
  end

  desc "Export information about a particular faculty member"
  task :export_one do
    # id = "jhogansc"
    id = "ldepuydt"
    uri = "http://vivo.brown.edu/individual/#{id}"
    triples = Export.faculty_one(uri)
    text = triples.join(" . \n") + " . \n"
    File.write("./#{id}.ttl", text)
  end
end
