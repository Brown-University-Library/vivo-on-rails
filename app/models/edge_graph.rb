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
end
