require "edge_graph"

class CollabGraph
  def initialize()
    @graph = EdgeGraph.new()
  end

  def self.collab_one(id)
    byebug
    collab = CollabGraph.new()
    graph = collab.graph_for(id)
    return graph.to_json
    network = {directed: "false", graph: {}, links: graph.links, nodes: graph.nodes}
    puts "NEW"
    puts network.to_json
    puts "=="
    puts "OLD"
    puts self.collab_one_ok(id)
    puts "  "
    return self.collab_one_ok(id)
  end

  def graph_for(id)
    get_collabs(id, 1)
    @graph
  end

  def get_collabs(id, level)
    return if level > 2
    faculty = Faculty.load_from_solr(id)
    return if faculty == nil

    # add a node for this faculty...
    node = {group: faculty.item.title, id: faculty.item.uri, name: faculty.item.name}
    @graph.add_node(node)

    # and process his/hers collaborators...
    faculty.item.collaborators.each do |collab|
      node = {group: collab.title, id: collab.uri, name: collab.name}
      link = {source: faculty.item.uri, target: collab.uri, weigth: 1}
      @graph.add_node(node)
      @graph.add_link(link)
      next_id = collab.uri.split("/").last
      get_collabs(next_id, level + 1)
    end
  end
end
