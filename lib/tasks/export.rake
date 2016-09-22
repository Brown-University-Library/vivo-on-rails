require "./app/models/export.rb"
namespace :vivo do
  desc "Export a list of all faculty members"
  task :export_all do
    count = 100
    triples = Export.faculty(count)
    text = triples.join()
    File.write('./all.ttl', text)
  end
end
