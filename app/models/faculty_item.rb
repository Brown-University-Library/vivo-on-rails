class FacultyItem
  include ModelUtils # needed for set_values_from_hash

  attr_accessor :record_type, :id, :uri, :overview, :email, :org_label, :name,
    :title, :contributor_to, :thumbnail, :education, :awards,
    :research_overview, :research_statement, :teacher_for,
    :teaching_overview, :scholarly_work, :funded_research,
    :collaborators, :affiliations_text, :affiliations, :research_areas,
    :web_page_text, :web_page_uri, :published_in

  def initialize(values = nil)
    init_defaults()
    set_values_from_hash(values)
    @id = uri
  end

  def init_defaults()
    @record_type = "PEOPLE"
    @affiliations_text = ""
    @affiliations = []
    @awards = ""
    @collaborators = []
    @contributor_to = []
    @published_in = []
    @education = []
    @email = ""
    @funded_research = ""
    @name = ""
    @org_label = ""
    @overview = ""
    @research_overview = ""
    @research_statement = ""
    @scholarly_work = ""
    @teacher_for = []
    @teaching_overview = ""
    @title = ""
    @thumbnail = ""
    @research_areas = []
    @web_page_text = ""
    @web_page_uri = ""
  end

  def contributor_to=(value)
    @contributor_to = value

    # Merge both contribution[:published_in] and
    # contribution[:venue_name] into faculty.published_in
    @published_in = []
    @contributor_to.each do |c|
      @published_in << c.published_in if c.published_in
      @published_in << c.venue_name if c.venue_name
    end

    @contributor_to
  end

  def self.from_hash(hash)
    faculty = FacultyItem.new(nil)
    hash.each do |key, value|
      getter = key.to_s
      case getter
      when "affiliations"
        faculty.affiliations = value.map {|v| AffiliationItem.new(v)}
      when "collaborators"
        faculty.collaborators = value.map {|v| CollaboratorItem.new(v)}
      when "contributor_to"
        faculty.contributor_to = value.map {|v| ContributorToItem.new(v)}
      when "education"
        faculty.education = value.map {|v| TrainingItem.new(v)}
      when "teacher_for"
        # string array, no special handling
        faculty.teacher_for = value
      when "research_areas"
        # string array, no special handling
        faculty.research_areas = value
      else
        setter = key.to_s + "="
        faculty.send(setter, value)
      end
    end
    faculty
  end
end
