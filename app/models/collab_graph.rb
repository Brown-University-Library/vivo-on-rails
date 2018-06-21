require "edge_graph"

class CollabGraph
  def initialize()
    @graph = EdgeGraph.new()
  end

  def graph_for_org(org_id, org_name)
    # add the members of the organization as root nodes (level 0)
    root_nodes = []
    organization = Organization.load_from_solr(org_id)
    organization.item.people.each do |member|
      faculty = Faculty.load_from_solr(member.vivo_id)
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
      root_nodes << member.vivo_id
    end

    # calculate the collaboration graph for each of them
    root_nodes.each do |id|
      get_collabs(id, 1)
    end

    @graph
  end

  def graph_for(id)
    get_collabs(id, 1)

    # Get the group (organization) for nodes that we don't have it yet.
    #
    # Nodes added directly in get_collabs() will have this value because
    # we fetch their full faculty record, however, because we don't fetch
    # the faculty information for collaborators added at the last level
    # of the graph the group value will be empty.
    @graph.nodes.each do |node|
      if node[:group] == nil
        short_id = ModelUtils.vivo_id(node[:id])
        faculty = Faculty.load_from_solr(id)
        node[:group] = faculty.item.org_label
      end
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
