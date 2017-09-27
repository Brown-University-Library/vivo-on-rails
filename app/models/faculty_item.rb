require "./app/models/model_utils.rb"
class FacultyItem

  attr_accessor :record_type, :id, :uri, :overview, :email, :org_label, :name,
    :title, :contributor_to, :thumbnail, :education, :awards,
    :research_overview, :research_statement, :teacher_for,
    :teaching_overview, :scholarly_work, :funded_research,
    :collaborators, :affiliations_text, :affiliations, :research_areas,
    :on_the_web, :appointments, :published_in, :hidden,
    :cv_link, :cv_link_text,
    :credentials, :training

  def initialize(values = nil)
    init_defaults()
    ModelUtils.set_values_from_hash(self, values)
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
    @on_the_web = []
    @appointments = []
    @hidden = false
    @credentials = []
    @training = []
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
        faculty.affiliations = value.map {|v| AffiliationItem.new(v)}.sort_by {|v| v.name.downcase}
      when "collaborators"
        faculty.collaborators = value.map {|v| CollaboratorItem.new(v)}
      when "contributor_to"
        faculty.contributor_to = value.map {|v| ContributorToItem.new(v)}
      when "education"
        faculty.education = value.map {|v| EducationItem.new(v)}
      when "appointments"
        faculty.appointments = value.map {|v| AppointmentItem.new(v)}
      when "credentials"
        faculty.credentials = value.map {|v| CredentialItem.new(v)}
      when "on_the_web"
        faculty.on_the_web = value.map {|v| OnTheWebItem.new(v)}
      when "training"
        faculty.training = value.map {|v| TrainingItem.new(v)}
      when "teacher_for"
        # string array, no special handling
        faculty.teacher_for = value
      when "research_areas"
        # string array, no special handling
        faculty.research_areas = value.sort_by {|a| a.downcase}
      when "thumbnail"
        faculty.thumbnail = ModelUtils.safe_thumbnail(value)
      else
        setter = key.to_s + "="
        if faculty.respond_to?(setter)
          faculty.send(setter, value)
        else
          # we've got a value in Solr that we don't expect/want.
        end
      end
    end
    faculty
  end
end
