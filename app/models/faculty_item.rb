class FacultyItem
  attr_accessor :uri, :overview, :email, :org_label, :label,
    :title, :contributor_to, :thumbnail, :education, :awards,
    :research_overview, :research_statement, :teacher_for,
    :teaching_overview, :scholarly_work, :funded_research,
    :collaborators, :affiliations_text, :affiliations

  URI_TITLE = "http://vivoweb.org/ontology/core#preferredTitle"
  URI_LABEL = "http://www.w3.org/2000/01/rdf-schema#label"
  URI_CONTRIBUTOR_TO = "http://vivo.brown.edu/ontology/citation#contributorTo"
  URI_OVERVIEW = "http://vivoweb.org/ontology/core#overview"
  URI_RESEARCH_OVERVIEW = "http://vivoweb.org/ontology/core#researchOverview"
  URI_RESEARCH_STATEMENT = "http://vivo.brown.edu/ontology/vivo-brown/researchStatement"
  URI_EMAIL = "http://vivoweb.org/ontology/core#primaryEmail"
  URI_PRIMARY_ORG_LABEL = "http://vivo.brown.edu/ontology/vivo-brown/primaryOrgLabel"
  URI_SCHOLARLY_WORK = "http://vivo.brown.edu/ontology/vivo-brown/scholarlyWork"
  URI_AWARDS_HONORS = "http://vivo.brown.edu/ontology/vivo-brown/awardsAndHonors"
  URI_FUNDED_RESEARCH = "http://vivo.brown.edu/ontology/vivo-brown/fundedResearch"
  URI_TEACHING_OVERVIEW = "http://vivoweb.org/ontology/core#teachingOverview"
  URI_AFFILIATIONS = "http://vivo.brown.edu/ontology/vivo-brown/affiliations"

  def self.field_mappings
    @mappings ||= begin
      mappings = []
      mappings << {uri: URI_OVERVIEW, prop: "overview"}
      mappings << {uri: URI_RESEARCH_OVERVIEW, prop: "research_overview"}
      mappings << {uri: URI_RESEARCH_STATEMENT, prop: "research_statement"}
      mappings << {uri: URI_SCHOLARLY_WORK, prop: "scholarly_work"}
      mappings << {uri: URI_EMAIL, prop: "email"}
      mappings << {uri: URI_PRIMARY_ORG_LABEL, prop: "org_label"}
      mappings << {uri: URI_LABEL, prop: "label"}
      mappings << {uri: URI_TITLE, prop: "title"}
      mappings << {uri: URI_AWARDS_HONORS, prop: "awards"}
      mappings << {uri: URI_FUNDED_RESEARCH, prop: "funded_research"}
      mappings << {uri: URI_TEACHING_OVERVIEW, prop: "teaching_overview"}
      mappings << {uri: URI_AFFILIATIONS, prop: "affiliations_text"}
      # mappings << {uri: URI_CONTRIBUTOR_TO, prop: "contributor_to", type: "a"}
      mappings
    end
  end

  def self.field_for_predicate(predicate)
    field_mappings.find {|mapping| mapping[:uri] == predicate}
  end

  def initialize()
    @affiliations_text = ""
    @affiliations = []
    @awards = ""
    @collaborators = []
    @contributor_to = []
    @education = []
    @email = ""
    @funded_research = ""
    @label = ""
    @org_label = ""
    @overview = ""
    @research_overview = ""
    @research_statement = ""
    @scholarly_work = ""
    @teacher_for = []
    @teaching_overview = ""
    @title = ""
    @thumbnail = ""
  end
end
