class FacultyPresenter
  attr_accessor :query, :form_values
  attr_accessor :faculty, :has_publications, :has_research, :has_background,
    :has_affiliations, :has_teaching, :has_details

  def initialize(faculty)
    @faculty = faculty

    @has_publications = faculty.contributor_to.count > 0

    @has_research = !faculty.research_overview.empty? ||
      !faculty.research_statement.empty? ||
      !faculty.funded_research.empty? ||
      !faculty.scholarly_work.empty?

    @has_background = faculty.education.count > 0 ||
      !faculty.awards.empty? ||
      faculty.on_the_web.count > 0

    @has_affiliations = faculty.collaborators.count > 0 ||
      !faculty.affiliations_text.empty? ||
      faculty.appointments.count > 0

    @has_teaching = !faculty.teaching_overview.empty? ||
      faculty.teacher_for.count > 0

    @has_details = @has_publications || @has_research ||
      @has_background || @has_affiliations || @has_teaching
  end
end
