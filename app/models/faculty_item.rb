class FacultyItem
  attr_accessor :uri, :overview, :email, :org_label, :label, :title,
    :contributor_to, :thumbnail, :education, :awards, :research_overview,
    :teaching

  URI_TITLE = "http://vivoweb.org/ontology/core#preferredTitle"
  URI_LABEL = "http://www.w3.org/2000/01/rdf-schema#label"
  URI_CONTRIBUTOR_TO = "http://vivo.brown.edu/ontology/citation#contributorTo"
  URI_OVERVIEW = "http://vivoweb.org/ontology/core#overview"
  URI_RESEARCH_OVERVIEW = "http://vivoweb.org/ontology/core#researchOverview"
  URI_EMAIL = "http://vivoweb.org/ontology/core#primaryEmail"
  URI_PRIMARY_ORG_LABEL = "http://vivo.brown.edu/ontology/vivo-brown/primaryOrgLabel"

  def self.field_mappings
    @mappings ||= begin
      mappings = []
      mappings << {uri: URI_OVERVIEW, prop: "overview"}
      mappings << {uri: URI_RESEARCH_OVERVIEW, prop: "research_overview"}
      mappings << {uri: URI_EMAIL, prop: "email"}
      mappings << {uri: URI_PRIMARY_ORG_LABEL, prop: "org_label"}
      mappings << {uri: URI_LABEL, prop: "label"}
      mappings << {uri: URI_TITLE, prop: "title"}
      mappings << {uri: URI_CONTRIBUTOR_TO, prop: "contributor_to", type: "a"}
      mappings
    end
  end

  def self.field_for_predicate(predicate)
    field_mappings.find {|mapping| mapping[:uri] == predicate}
  end

  def initialize()
    @overview = ""
    @email = ""
    @org_label = ""
    @label = ""
    @title = ""
    @contributor_to = []
    @thumbnail = ""
    @education = []
    @awards = ""
    @research_overview = ""
    @teaching = []
  end
end
