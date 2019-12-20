class Team
    attr_accessor :id, :name, :members

    def initialize(id, name)
        @id = id
        @name = name
        @members = []       # Array of Faculty
    end

    def members_ids()
        @members.map {|x| x.item.vivo_id }
    end

    # For now we only recognize a few hard-coded teams
    def self.find_by_id(id, load = false)
        team = nil
        case
        when id == "team-crisp"
            team = Team.new("team-crisp", "Consortium for Research and Innovation in Suicide Prevention")
            member_ids = ["sarias1", "ma1", "jbarredo", "lbrick", "ac67", "echen13", "ddickste",
                "yduartev", "mjfrank", "bgaudian", "rnjones", "kkemp",
                "rl11", "bm8", "imilleri", "nnugent", "jprimack", "mranney",
                "hschatte", "aspirito", "luebelac", "lweinsto", "jw33", "syenphd"]
            if load
                team.members = Faculty.load_from_solr_many(member_ids)
            end

        when id == "team-star"
            team = Team.new("team-star", "Institute on Stress, Trauma, and Resilience")
            member_ids = ["atyrka", "lstroud", "sparade", "nnugent"]
            if load
                team.members = Faculty.load_from_solr_many(member_ids)
            end

        when id == "team-advctr"
            team = Team.new("team-advctr", "Advance CTR (Brown + URI) *draft*")
            if load
                team.members = self.advancectr_members()
            end
        end

        team
    end

    def self.id_from_name(name)
        name.downcase.gsub(/[^a-z0-9]/,"-")
    end

    def self.advancectr_members
        # Get all the information for the people in this team
        # Note that this code depends on a very specific format in
        # the TSV file.
        filename = ENV["ADVANCECTR_DATA"]
        flat_data = []
        CSV.foreach(filename, {headers: :first_row, col_sep: "\t"}) do |row|

            inv = row["investigator"]
            inst = row["institution"]
            id = "http://#{id_from_name(inst)}/#{id_from_name(inv)}"

            collab = row["collaborator"]
            collab_inst = row["collaborator_institution"]
            collab_id = "http://#{id_from_name(collab_inst)}/#{id_from_name(collab)}"

            next if inv == nil
            flat_item = {
                id: id,
                email: "EMAIL",
                name: inv,
                department: inst,
                institution_name: inst,
                collab_id: collab_id,
                collab_name: collab,
                collab_dept: collab_inst,
                sponsor_id: ""
            }
            flat_data << flat_item
        end

        # Calculate the unique member IDs
        ids = flat_data.map {|x| x[:id]}
        ids += flat_data.map {|x| x[:collab_id]}
        uniq_ids = ids.sort.uniq

        # Create a faculty list (with collaborators)
        # from the flat data.
        faculty_list = []
        uniq_ids.each do |id|
            info = flat_data.find {|x| x[:id] == id}
            if info != nil
                # The faculty record...
                faculty = Faculty.new()
                faculty.item = FacultyItem.new()
                faculty.item.uri = id
                faculty.item.id = id
                faculty.item.name = info[:name]
                faculty.item.display_name = info[:name]
                faculty.item.title = info[:department]
                faculty.item.org_label = info[:department]
                faculty.item.collaborators = []
                # ...and their collaborators
                collabs = flat_data.select {|x| x[:id] == id}
                collabs.each do |info|
                    collab = CollaboratorItem.new({})
                    collab.uri = info[:collab_id]
                    collab.name = info[:collab_name]
                    collab.org_name = info[:collab_dept]
                    collab.title = nil
                    faculty.item.collaborators << collab
                end
                faculty_list << faculty
            end
        end

        faculty_list
    end
  end
