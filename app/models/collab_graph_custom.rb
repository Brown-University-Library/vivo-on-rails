require "edge_graph"

class CollabGraphCustom
  def initialize()
    @graph = EdgeGraph.new()
  end

  def graph_for_team(id, research_area = nil)
    org = Organization.for_team(id)
    graph_for_list(org.faculty_list(), org.item.name, research_area)
  end

  def graph_for_list(faculty_list, org_name, research_area = nil)
    # add the members of the organization as root nodes (level 0)
    root_nodes = []
    faculty_list.each do |faculty|
      @graph.research_areas += faculty.item.research_areas.map {|r| r.strip.downcase }
      if research_area != nil
        if !faculty.item.research_on(research_area)
          # skip if researcher is not involved in
          # the research area that we are interested
          next
        end
      end

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
      root_nodes << faculty.item.vivo_id
    end

    # calculate the collaboration graph for each of them
    root_nodes.uniq.each do |id|
      get_collabs(id, 1, research_area)
    end

    # TODO: preserve the count of how many people have that research area
    @graph.research_areas.uniq!
    @graph.research_areas.sort!
    @graph
  end

  def get_collabs(id, level, research_area = nil)
    return if level > 2
    faculty = Faculty.load_from_solr(id)
    return if faculty == nil
    return if research_area != nil && !faculty.item.research_on(research_area)

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

      if research_area != nil
        collab_faculty = Faculty.load_from_solr(collab.short_id)
        next if (collab_faculty == nil || !collab_faculty.item.research_on(research_area))
      end

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
      get_collabs(next_id, level + 1, research_area)
    end
  end
end