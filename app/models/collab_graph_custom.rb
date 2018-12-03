require "edge_graph"

class CollabGraphCustom
  def initialize()
    @graph = EdgeGraph.new()
  end

  def graph_for_team(id)
    members = []
    org = Organization.for_team(id)
    org.item.people.each do |faculty|
      members << faculty.vivo_id
    end
    graph_for_org(members, org.item.name)
  end

  def graph_for_org(members, org_name)
    # add the members of the organization as root nodes (level 0)
    root_nodes = []
    members.each do |id|
      faculty = Faculty.load_from_solr(id)
      next if faculty == nil
      # Notice that we use the passed org_name to prevent
      # inconsistencies with faculty that belong to many
      # organizations.
      node = {
        group: org_name,
        title: faculty.item.title,
        id: faculty.item.uri,
        name: faculty.item.name,
        level: 0}
      @graph.add_node(node)
      root_nodes << id
    end

    # calculate the collaboration graph for each of them
    root_nodes.uniq.each do |id|
      get_collabs(id, 1)
    end

    @graph
  end

  def get_collabs(id, level)
    return if level > 2
    faculty = Faculty.load_from_solr(id)
    return if faculty == nil

    # add a node for this faculty...
    node = {
      group: faculty.item.org_label,
      title: faculty.item.title,
      id: faculty.item.uri,
      name: faculty.item.name,
      level: level-1}
    @graph.add_node(node)

    # and process his/hers collaborators...
    faculty.item.collaborators.each do |collab|
      node = {
        group: nil,
        title: collab.title,
        id: collab.uri,
        name: collab.name,
        level: level
      }
      link = {source: faculty.item.uri, target: collab.uri, weight: 1}
      @graph.add_node(node)
      @graph.add_link(link)
      next_id = collab.uri.split("/").last
      get_collabs(next_id, level + 1)
    end
  end
end