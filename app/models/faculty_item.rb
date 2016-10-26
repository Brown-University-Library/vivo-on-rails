class FacultyItem
  attr_accessor :record_type, :uri, :overview, :email, :org_label, :name,
    :title, :contributor_to, :thumbnail, :education, :awards,
    :research_overview, :research_statement, :teacher_for,
    :teaching_overview, :scholarly_work, :funded_research,
    :collaborators, :affiliations_text, :affiliations
  attr_reader :id

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
end
