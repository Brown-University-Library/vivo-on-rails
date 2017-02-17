require "./app/models/faculty_solrize.rb"
require "./app/models/organization_solrize.rb"
namespace :vivo do
  desc "Sends to Solr information about all faculty members"
  task :solrize_faculty_all => :environment do
    solr = FacultySolrize.new(solr_url)
    solr.add_all()
  end

  desc "Sends to Solr information about faculty members not already in Solr"
  task :solrize_faculty_new => :environment  do
    solr = FacultySolrize.new(solr_url)
    solr.add_new()
  end

  desc "Sends to Solr information about one faculty member"
  task :solrize_faculty_one, [:vivo_id] => :environment do |cmd, args|
    vivo_id = args[:vivo_id]
    abort "No vivo_id was provided" if vivo_id == nil
    solr = FacultySolrize.new(solr_url)
    solr.add_one(vivo_id)
  end

  desc "Outputs the JSON that would be solrized for an individual faculty"
  task :solrize_faculty_json, [:vivo_id] => :environment do |cmd, args|
    vivo_id = args[:vivo_id]
    abort "No vivo_id was provided" if vivo_id == nil
    solr = FacultySolrize.new(solr_url)
    puts solr.get_json(vivo_id)
  end

  desc "Sends to Solr information about all organizations"
  task :solrize_org_all => :environment  do
    solr = OrganizationSolrize.new(solr_url)
    solr.add_all()
  end

  desc "Sends to Solr information about one organization"
  task :solrize_org_one => :environment do |cmd, args|
    solr = OrganizationSolrize.new(solr_url)
    id = "org-brown-univ-dept57"
    solr.add_one(id)
  end

  desc "Outputs the JSON that would be solrized for an individual organization"
  task :solrize_org_json, [:vivo_id] => :environment do |cmd, args|
    vivo_id = args[:vivo_id]
    abort "No vivo_id was provided" if vivo_id == nil
    solr = OrganizationSolrize.new(solr_url)
    puts solr.get_json(vivo_id)
  end

  desc "Deletes all data from Solr (faculty and organization)"
  task :solrize_delete_all => :environment  do
    solr = SolrLite::Solr.new(solr_url)
    solr.delete_all!()
  end

  def solr_url
    solr_url = ENV["SOLR_URL"]
  end
end
