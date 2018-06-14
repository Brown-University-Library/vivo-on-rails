require "csv"

class EdgeGraph
  # EdgeGraph represents the data in a graph that can be used in an Edge Graph
  # visualization in D3.
  #
  # links is an array of {source: s, target: t, weight: w}
  # nodes is an array of {group: g, id: i, name: n}
  attr_reader :directed, :graph, :links, :nodes

  def initialize
    @directed = "false"
    @graph = {}
    @links = []
    @nodes = []
  end

  # Creates and initializes a new EdgeGraph with the data in Hash
  # that is expected to have :nodes and :links arrays with the proper
  # structure (as documented in the `initialize()` method above)
  def self.new_from_hash(json)
    graph = EdgeGraph.new()
    json[:nodes].each do |node|
      graph.add_node(node)
    end

    json[:links].each do |link|
      graph.add_link(link)
    end

    graph
  end

  def add_node(new_node)
    node_found = nil
    @nodes.each do |node|
      if node[:id] == new_node[:id]
        node_found = node
        break
      end
    end
    if node_found == nil
      @nodes << new_node
    end
  end

  def add_link(new_link)
    link_found = false
    @links.each do |link|
      if link[:source] == new_link[:source] && link[:target] == new_link[:target]
        link[:weight] += 1
        link_found = true
        break
      end
    end
    if !link_found
      @links << new_link
    end
  end

  def find_node(id)
    @nodes.each do |node|
      if node[:id] == id
        return node
      end
    end
    nil
  end

  def to_csv
    return "" if @links.count == 0
    str = CSV.generate do |csv|
      csv << ["id", "name", "info", "collab_with", "count"]
      @links.each do |link|
        source = find_node(link[:source])
        target = find_node(link[:target])
        csv << [source[:id], source[:name], source[:group], target[:id], link[:weight]]
      end
    end
    str
  end
end
