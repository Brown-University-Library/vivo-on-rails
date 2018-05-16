require "edge_graph"

class CollabGraph
  def initialize()
    @graph = EdgeGraph.new()
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
