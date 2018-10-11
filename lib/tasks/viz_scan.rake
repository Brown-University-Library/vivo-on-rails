require "csv"
require "byebug"
require "./app/models/search.rb"
namespace :vivo do
  desc "Determines which faculty will have visualizations"
  task :viz_scan => :environment do
    file_in = "./biomed_affiliated.csv"
    file_out = "./biomed_affiliated_2.csv"

    puts "Fetching coauthors..."
    ok, str = ModelUtils.http_get_body("#{ENV['VIZ_SERVICE_URL']}/coauthors/")
    if !ok
      puts "Could not fetch coauthors list"
    end
    coauthors = JSON.parse(str)

    puts "Fetching collaborators..."
    ok, str = ModelUtils.http_get_body("#{ENV['VIZ_SERVICE_URL']}/collaborators/")
    if !ok
      puts "Could not fetch collaborators list"
    end
    collabs = JSON.parse(str)

    puts "Calculating..."
    i = 0
    output = []
    CSV.foreach(file_in, {headers: true}) do |row|
      i += 1
      if (i%100) == 0
        puts "processing #{i}"
      end
      uri = row["fac"]
      id = uri.split("/").last

      has_coauthor = (coauthors[uri] != nil)
      has_collab = false
      if collabs[uri] != nil
        ok, str = ModelUtils.http_get_body(collabs[uri])
        graph = JsonUtils.safe_parse(str)
        if graph && graph["graph"] && graph["graph"]["nodes"]
          has_collab = graph["graph"]["nodes"].count > 1
        end
      end

      out = {
        id: id,
        vivo_url: "N/A",
        name: row["name"],
        affiliation: row["label"],
        coauthor: has_coauthor,
        collab: has_collab,
        coauthor_url: nil,
        treemap_url: nil,
        collab_url: nil
      }

      if in_solr?(id)
        out[:vivo_url] = "https://vivo.brown.edu/display/#{id}"
      end

      if out[:coauthor]
        out[:coauthor_url] = "https://vivo.brown.edu/display/#{id}/viz/coauthor"
        out[:treemap_url] = "https://vivo.brown.edu/display/#{id}/viz/coauthor_treemap"
      end

      if out[:collab]
        out[:collab_url] = "https://vivo.brown.edu/display/#{id}/viz/collab"
      end
      output << out
    end

    # Create a CSV file with the output
    puts "Saving..."
    CSV.open(file_out, "wb") do |csv|
      header = ["name", "affiliation", "id", "coauthors?", "collaborators?",
        "coauthor_viz", "coauthor_treemap_viz", "collaborator_viz"]
      csv << header
      output.each do |rec|
        id = rec[:id] == nil ? "--" : rec[:id]
        row = [
          rec[:name], rec[:affiliation], rec[:vivo_url],
          rec[:coauthor], rec[:collab],
          rec[:coauthor_url], rec[:treemap_url], rec[:collab_url]
        ]
        csv << row
      end
    end
    puts "done"
  end
end

def in_solr?(id)
  ok, body = ModelUtils.http_get_body("https://vivo.brown.edu/display/#{id}.json")
  ok
end

def get_id(name)
  id = nil
  search = Search.new(ENV["SOLR_URL"])
  params = SolrLite::SearchParams.new(name)
  results = search.search(params)
  first = results.items.first
  if first != nil && first.name == name
    id = first.vivo_id
  end
  id
end

def coauthor_network?(id)
  ok, data = CoauthorGraph.get_data(id)
  ok && data != nil
end

def collab_network?(id)
  ok, data = CollabGraph.get_data(id)
  ok && data != nil
end
