require "edge_graph"
require "model_utils"
require "collab_graph_custom"

class CollabGraph
  # Fetches the collaboration graph from the data service for a given ID.
  # The ID must represent a person or an organization.
  #
  # Returns [ok, data]
  #
  # ok is true if no errors were detected, in which case data contains the
  # collaboration information in hash with the following structure:
  # {
  #   graph: {
  #     links: [{source: id, target: id, weight: n}, ...],
  #     nodes: [{group: x, id: id, name: x, title: x}, ...],
  #   }
  #   rabid: x,
  #   updated: "yyyy-mm-dd"
  # }
  #
  # ok is false we could not retrieve the data. In this case data is a
  # hash with the following structure: { staus: nnn, message: xxx}
  #
  def self.get_data(id)
    type = ModelUtils.type_for_id(id)
    if type != "PEOPLE" && type != "ORGANIZATION" && type != "TEAM"
      return false, {status: 404, message: "Could not retrieve collaboration graph for #{id} (invalid type)"}
    end

    if type == "TEAM"
      # Custom code to fetch the data since teams are hard-coded
      # in the Rails app. Eventually teams will be defined in
      # the VIVO and collaboration information will be served by
      # the Visualization Service, but we are not there yet.
      cache_key = "team_collab_" + id
      graph = Rails.cache.fetch(cache_key, expires_in: 5.minute) do
        Rails.logger.info "Caching #{cache_key}..."
        org = Organization.load(id)
        g = CollabGraphCustom.new()
        label = (id == "team-advctr") ? nil : org.item.name
        g.graph_for_list(org.faculty_list(), label)
      end

      yesterday = (Date.today-1).to_s
      data = {graph: graph, rabid: id, updated: yesterday}
      return true, data
    end

    if id == "org-brown-univ-dept148" || id == "org-brown-univ-dept124"
      # Custom code to fetch the data for the Swearer Center
      # and the Cogut Institute since membership to these organizations
      # is not (yet) stored in the triplestore and therefore we must
      # calculate the graph on the fly.
      cache_key = "team_collab_" + id
      graph = Rails.cache.fetch(cache_key, expires_in: 5.minute) do
        Rails.logger.info "Caching #{cache_key}..."
        org = Organization.load(id)
        g = CollabGraphCustom.new()
        g.graph_for_list(org.faculty_list(), org.item.name)
      end
      yesterday = (Date.today-1).to_s
      data = {graph: graph, rabid: id, updated: yesterday}
      return true, data
    end

    url = "#{ENV['VIZ_SERVICE_URL']}/collaborators/#{id}"
    ok, str = ModelUtils.http_get_body(url)
    if !ok
      return false, {status: 500, message: "Could not retrieve collaboration graph for #{id}"}
    end

    data = JSON.parse(str, {symbolize_names: true})
    return true, data
  end

  # Same as get_data() but converts to comma separated values the returning
  # graph. In other words, it returns a string with the data as CSV.
  def self.get_data_csv(id)
    ok, data = self.get_data(id)
    if !ok
      return false, data
    end

    graph = nil
    if data[:graph].is_a?(EdgeGraph)
      # Special case for "teams", see get_data() above.
      # Should refactor this when we fully implement teams.
      graph = data[:graph]
    else
      # Dump it to an EdgeGraph in order to produce the CSV output
      # and reset the weight to 1 since is meaninless here.
      graph = EdgeGraph.new_from_hash(data[:graph])
    end

    graph.links {|link| link.weight = 1}
    return true, graph.to_csv()
  end

  def self.get_list()
    url = "#{ENV['VIZ_SERVICE_URL']}/collaborators/"
    ok, str = ModelUtils.http_get_body(url)
    if !ok
      return false, {status: 500, message: "Could not retrieve collaborators graph list"}
    end

    data = JSON.parse(str, {symbolize_names: false})
    return true, data
  end
end
