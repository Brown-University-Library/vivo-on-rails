class Team
    attr_accessor :id, :name, :member_ids

    def initialize(id, name)
        @id = id
        @name = name
        @member_ids = []
    end

    # For now we only recognize a couple of teams
    def self.find_by_id(id)
        team = nil
        case
        when id == "team-crisp"
            team = Team.new("team-crisp", "Consortium for Research and Innovation in Suicide Prevention")
            team.member_ids = ["sarias1", "ma1", "jbarredo", "lbrick", "ac67", "echen13", "ddickste",
                "yduartev", "mjfrank", "bgaudian", "rnjones", "kkemp",
                "rl11", "bm8", "imilleri", "nnugent", "jprimack", "mranney",
                "hschatte", "aspirito", "luebelac", "lweinsto", "jw33", "syenphd"]
        when id == "team-star"
            team = Team.new("team-star", "Institute on Stress, Trauma, and Resilience")
            team.member_ids = ["atyrka", "lstroud", "sparade", "nnugent"]
        end
        team
    end
  end
