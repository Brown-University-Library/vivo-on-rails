require "./app/models/model_utils.rb"
class FacultyItem

  attr_accessor :record_type, :id, :uri, :overview, :email, :org_label, :name,
    :display_name, :title, :contributor_to, :thumbnail, :education, :awards,
    :research_overview, :research_statement, :teacher_for,
    :teaching_overview, :scholarly_work, :funded_research,
    :collaborators, :affiliations_text, :affiliations, :research_areas,
    :on_the_web, :appointments, :published_in, :hidden,
    :cv_link, :credentials, :training,
    :fis_updated, :profile_updated, :show_visualizations,
    :has_coauthors

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
    @display_name = ""
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
    @cv_link = nil
    @credentials = []
    @training = []
    @fis_updated = nil
    @profile_updated = nil
    @show_visualizations = false
    @has_coauthors = false
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end

  def self.from_hash(hash, display_name, thumbnail_url, fis_updated, profile_updated, show_viz)
    faculty = FacultyItem.new(nil)
    faculty.thumbnail = thumbnail_url
    faculty.fis_updated = fis_updated
    faculty.profile_updated = profile_updated
    faculty.show_visualizations = show_viz
    hash.each do |key, value|
      getter = key.to_s
      begin
        case getter
        when "affiliations"
          faculty.affiliations = AffiliationItem.from_hash_array(value)
        when "collaborators"
          faculty.collaborators = CollaboratorItem.from_hash_array(value)
        when "contributor_to"
          faculty.contributor_to = ContributorToItem.from_hash_array(value)
        when "education"
          faculty.education = EducationItem.from_hash_array(value)
        when "appointments"
          faculty.appointments = AppointmentItem.from_hash_array(value)
        when "credentials"
          faculty.credentials = CredentialItem.from_hash_array(value)
        when "on_the_web"
          faculty.on_the_web = OnTheWebItem.from_hash_array(value)
        when "training"
          faculty.training = TrainingItem.from_hash_array(value)
        when "cv"
          faculty.cv_link = get_cv_link(value)
        when "teacher_for"
          # string array, no special handling
          faculty.teacher_for = value.sort_by {|a| (a || "").downcase}
        when "research_areas"
          # string array, no special handling
          faculty.research_areas = value.sort_by {|a| (a || "").downcase}
        when "thumbnail"
          # Ignore this value, we use thumbnail_url parameter instead
        else
          setter = key.to_s + "="
          if faculty.respond_to?(setter)
            faculty.send(setter, value)
          else
            # we've got a value in Solr that we don't expect/want.
            Rails.logger.warn("Unexpected field #{key} received for faculty #{hash['uri']}")
          end
        end
      rescue => ex
        backtrace = ex.backtrace.join("\r\n")
        Rails.logger.error("Error parsing data for Faculty #{hash['uri']} (#{display_name}). Exception: #{ex} \r\n #{backtrace}")
      end
    end

    if display_name != nil
      faculty.display_name = display_name
    else
      faculty.display_name = faculty.name || ""
    end

    faculty
  end

  def self.get_cv_link(values)
    if values == nil || values.length == 0
      return nil
    end
    values[0]["cv_link"]
  end
end
