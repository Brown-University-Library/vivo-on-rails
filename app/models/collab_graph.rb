require "edge_graph"

class CollabGraph
  def initialize()
    @graph = EdgeGraph.new()
  end

  def graph_for_org(org_id)
    organization = Organization.load_from_solr(org_id)
    organization.item.people.each do |faculty|
      get_collabs(faculty.vivo_id, 1)
    end
    @graph
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
    node = {group: faculty.item.title, id: faculty.item.uri, name: faculty.item.name, level: level-1}
    @graph.add_node(node)

    # and process his/hers collaborators...
    faculty.item.collaborators.each do |collab|
      node = {group: collab.title, id: collab.uri, name: collab.name, level: level}
      link = {source: faculty.item.uri, target: collab.uri, weight: 1}
      @graph.add_node(node)
      @graph.add_link(link)
      next_id = collab.uri.split("/").last
      get_collabs(next_id, level + 1)
    end
  end
end
