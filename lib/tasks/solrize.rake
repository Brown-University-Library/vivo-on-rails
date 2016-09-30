require "./app/models/faculty_solrize.rb"
namespace :vivo do
  desc "Send to Solr information about all faculty members"
  task :solrize_all do
    solr = FacultySolrize.new(solr_url)
    solr.add_all()
  end

  desc "Send to Solr information about one faculty member"
  task :solrize_one do
    solr = FacultySolrize.new(solr_url)
    id = "cxbauer"
    solr.add_one(id)
  end

  desc "Delete all data from Solr"
  task :solrize_delete_all do
    solr = Solr::Solr.new(solr_url)
    solr.delete_all!()
  end

  def solr_url
    solr_url = ENV["SOLR_URL"]
  end
end
