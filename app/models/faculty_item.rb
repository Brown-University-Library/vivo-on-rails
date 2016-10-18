class FacultyItem
  attr_accessor :uri, :overview, :email, :org_label, :label,
    :title, :contributor_to, :thumbnail, :education, :awards,
    :research_overview, :research_statement, :teacher_for,
    :teaching_overview, :scholarly_work, :funded_research,
    :collaborators, :affiliations_text, :affiliations

  def initialize(values = nil )
    init_defaults()
    set_values(values)
  end

  def init_defaults()
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

  def set_values(values)
    return if values == nil
    values.keys.each do |key|
      setter = key.to_s + "="
      if self.respond_to?(setter)
        self.send(setter, values[key])
      end
    end
  end
end
