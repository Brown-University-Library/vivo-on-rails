require "edge_graph"
require "model_utils"

class CollabGraphCustom
  def initialize()
    @graph = EdgeGraph.new()
    @max_depth = 2
  end

  def graph_for_list(faculty_list, org_name)
    # Add the members of the organization as root nodes (level 0)
    root_nodes = []
    faculty_list.each do |faculty|
      node = {
        group: faculty.item.org_label,
        title: faculty.item.title,
        id: faculty.item.uri,
        name: faculty.item.name,
        level: 0,
        faculty: faculty
      }

      # If we got an org_name as a parameter use that one instead
      # (this is to preven inconsistencies with faculty that belong
      # to many organizations.)
      if org_name != nil
        node[:group] = org_name
      end

      found = root_nodes.find {|x| x[:id] == faculty.item.uri}
      if !found
        @graph.add_node(node)
        root_nodes << node
      end
    end

    # Walk the collaboration graph for each of the root nodes
    root_nodes.each do |node|
      get_collabs(node[:faculty], 1)
    end

    @graph
  end

  def get_collabs(faculty, level)
    return if level > @max_depth
    return if faculty == nil

    # add a node for this faculty...
    node = {
      group: faculty.item.org_label,
      title: faculty.item.title,
      id: faculty.item.uri,
      name: faculty.item.name,
      level: level-1}
    @graph.add_node(node)

    # and process their collaborators...
    faculty.item.collaborators.each do |collab|
      node = {
        group: collab.org_name,
        title: collab.title,
        id: collab.uri,
        name: collab.name,
        level: level
      }
      link = {source: faculty.item.uri, target: collab.uri, weight: 1}
      @graph.add_node(node)
      @graph.add_link(link)

      # For Brown faculty we go one level down in the graph (because
      # we have their data). For non-Brown we cannot.
      if ModelUtils::brown_vivo?(collab.uri)
        next_faculty = Faculty.load_from_solr(ModelUtils::vivo_id(collab.uri))
        get_collabs(next_faculty, level + 1)
      end
    end
  end
end