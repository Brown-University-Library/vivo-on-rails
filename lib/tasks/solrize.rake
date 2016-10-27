require "./app/models/faculty_solrize.rb"
require "./app/models/organization_solrize.rb"
namespace :vivo do
  desc "Sends to Solr information about all faculty members"
  task :solrize_faculty_all do
    solr = FacultySolrize.new(solr_url)
    solr.add_all()
  end

  desc "Sends to Solr information about faculty members not already in Solr"
  task :solrize_faculty_new do
    solr = FacultySolrize.new(solr_url)
    solr.add_new()
  end

  desc "Sends to Solr information about one faculty member"
  task :solrize_faculty_one do
    solr = FacultySolrize.new(solr_url)
    id = "lbestock"
    solr.add_one(id)
  end

  desc "Outputs the JSON that would be solrized for an individual faculty"
  task :solrize_faculty_json do
    solr = FacultySolrize.new(solr_url)
    id = "lbestock"
    id = "tflaniga"
    puts solr.get_json(id)
  end

  desc "Sends to Solr information about all organizations"
  task :solrize_org_all do
    solr = OrganizationSolrize.new(solr_url)
    solr.add_all()
  end

  desc "Sends to Solr information about one organization"
  task :solrize_org_one do
    solr = OrganizationSolrize.new(solr_url)
    id = "org-brown-univ-dept57"
    solr.add_one(id)
  end

  desc "Outputs the JSON that would be solrized for an individual organization"
  task :solrize_org_json do
    solr = OrganizationSolrize.new(solr_url)
    id = "org-brown-univ-dept57"
    puts solr.get_json(id)
  end

  desc "Deletes all data from Solr (faculty and organization)"
  task :solrize_delete_all do
    solr = Solr::Solr.new(solr_url)
    solr.delete_all!()
  end

  def solr_url
    solr_url = ENV["SOLR_URL"]
  end
end
