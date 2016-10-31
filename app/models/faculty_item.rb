class FacultyItem
  attr_accessor :record_type, :id, :uri, :overview, :email, :org_label, :name,
    :title, :contributor_to, :thumbnail, :education, :awards,
    :research_overview, :research_statement, :teacher_for,
    :teaching_overview, :scholarly_work, :funded_research,
    :collaborators, :affiliations_text, :affiliations, :research_areas
  # attr_reader :id

  def initialize(values = nil )
    init_defaults()
    set_values(values)
    @id = uri
  end

  def init_defaults()
    @record_type = "PEOPLE"
    @affiliations_text = ""
    @affiliations = []
    @awards = ""
    @collaborators = []
    @contributor_to = []
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
  end

  def set_values(hash)
    return if hash == nil
    hash.each do |key, value|
      getter = key.to_s
      setter = key.to_s + "="
      if self.respond_to?(setter)
        if value.class == Array
          if self.send(getter).class == Array
            self.send(setter, value)
          else
            # If we got an array but we were not expecting one
            # just get the first value (this is useful when
            # handling values from Solr)
            self.send(setter, value.first)
          end
        else
          self.send(setter, value)
        end
      end
    end
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
