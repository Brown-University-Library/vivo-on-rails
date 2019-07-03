# For information on Alluvial Diagrams see:
#   http://bl.ocks.org/igorzilla/3086583
#   https://rawgraphs.io/learning/how-to-make-an-alluvial-diagram/
#   https://bost.ocks.org/mike/sankey/
#   https://medium.com/@Elijah_Meeks/alluvial-charts-and-their-discontents-10a77d55216b
class AlluvialGraph
    attr_reader :data

    def initialize(faculty_list)
        @data = calc_graph(faculty_list)
    end

    # Calculates the data structure to draw an Alluvial Diagram.
    # The resulting structure has the following format:
    #
    #   {
    #       nodes: array of two elements
    #       links: array with the connections
    #   }
    #
    # The first nodes element is an array with the faculty information.
    # The second nodes element is an array with the research areas.
    #
    # Links is an array that describes the connections between faculty
    # (nodes[0]) and the research areas (nodes[1]).
    #
    def calc_graph(faculty_list)
        # Add faculty as nodes and give them a local id.
        nodes1 = []
        local_id = 0
        faculty_list.each do |faculty|
            local_id += 1
            node = {
                id: local_id,
                nodeName: faculty.item.vivo_id,
                incoming: [],
                nodeValue: 20
            }
            nodes1 << node
        end

        # Get the list of research areas for these faculty.
        areas_all = []
        faculty_list.each do |faculty|
            areas_all += faculty.item.research_areas
        end
        areas = areas_filtered(areas_all)

        # Add the research areas as nodes and givem them a local id.
        next_id = local_id + 1
        nodes2 = areas.each_with_index.map do |area, i|
            {
                id: next_id + i,
                nodeName: area[:key],
                incoming: [],
                nodeValue: area[:count] * 20,
                count: area[:count]
            }
        end

        # Create the links between researchers (nodes1) and research
        # areas (nodes2)
        links = []
        faculty_list.each do |faculty|
            node1 = nodes1.find {|n| n[:nodeName] == faculty.item.vivo_id}
            faculty.item.research_areas.each do |ra|
                node2 = nodes2.find {|a| a[:nodeName] == ra}
                if node2 == nil
                    # ignore this research area since it's not shared with anyone else
                else
                    # shared research area, add a link for it
                    weight = node2[:count] * 4
                    link = {
                        source: node1[:id],     # researcher
                        target: node2[:id],     # research area
                        value: weight
                    }
                    links << link
                end
            end
        end

        data = {nodes: [nodes1, nodes2], links: links}
        return data
    end

    private
        # Sort areas descending by count and only return the
        # ones that appear more than once (i.e. count > 1)
        def areas_filtered(areas_all)
            areas_counts = {}
            areas_all.each do |a|
                if areas_counts[a] == nil
                    areas_counts[a] = 1
                else
                    areas_counts[a] += 1
                end
            end

            # Get the ones that are shared (c > 1) into an array of key/count hashes
            areas = areas_counts.select { |k, c| c > 1 }
            areas = areas.map { |k, c| {key:k, count:c} }

            # Sort them descending
            areas = areas.sort { |a, b| a[:count] <=> b[:count]}.reverse
            areas
        end
end