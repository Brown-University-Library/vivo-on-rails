require "cgi"
require "./app/models/faculty.rb"
require "./lib/solr/solr.rb"
require "./lib/solr/search_params.rb"
require "./lib/solr/search_results.rb"
class FacultySolrize
  def initialize(solr_url)
    @solr_url = solr_url
    @solr = Solr::Solr.new(@solr_url)
    #@format = "v1"
    @format = "v2"
  end

  def add_all()
    uris = Faculty.all_uris
    puts "Processing #{uris.count} faculty records..."
    uris.each_with_index do |uri, i|
      id = uri.split("/").last
      json = get_json(id)
      @solr.update(json)
      if ((i+1) % 100) == 0
        @solr.commit()
        puts "...#{i+1}"
      end
    end
    @solr.commit()
  end

  def add_new()
    params = Solr::SearchParams.new()
    params.fl = ["uri"]
    uris = Faculty.all_uris
    puts "Processing #{uris.count} faculty records..."
    uris.each_with_index do |uri, i|
      params.q = "uri:" + CGI::escape('"') + uri + CGI::escape('"')
      solr_response = @solr.search(params)
      results = Solr::SearchResults.new(solr_response)
      if results.num_found == 0
        id = uri.split("/").last
        json = get_json(id)
        @solr.update_fast(json)
        puts "added (#{i+1}) #{uri}"
        if ((i+1) % 100) == 0
          @solr.commit()
          puts "commit (#{i+1})"
        end
      else
        puts "skipped (#{i+1})#{uri}"
      end
    end
    @solr.commit()
  end

  def add_one(id)
    json = get_json(id)
    @solr.update(json)
  end

  def get_json(id)
    faculty = Faculty.get_one_from_fuseki(id)
    if @format == "v1"
      # JSON for the PORO Faculty.
      JSON.pretty_generate(JSON.parse(faculty.to_json))
    else
      # JSON with a few fields.
      # Text has the JSON for PORO Faculty.
      solr_obj = {
        id: faculty.id,
        record_type: faculty.record_type,
        affiliations: faculty.affiliations.map { |a| a.name},
        text: faculty.to_json}
      solr_obj.to_json
    end
  end
end
