class FacultyPresenter
  attr_accessor :query, :form_values
  attr_accessor :faculty, :has_publications, :has_research, :has_background,
    :has_affiliations, :has_teaching, :has_details,
    :publication_filters,
    :show_back_to_search

  def initialize(faculty, search_url, referer)
    @faculty = faculty

    # Show it only if we are coming to the faculty page from a search
    @show_back_to_search = referer && referer.start_with?(search_url)

    @has_publications = faculty.contributor_to.count > 0
    @publication_filters = get_publication_filters()

    @has_research = !faculty.research_overview.empty? ||
      !faculty.research_statement.empty? ||
      !faculty.funded_research.empty? ||
      !faculty.scholarly_work.empty?

    @has_background = faculty.education.count > 0 ||
      !faculty.awards.empty? ||
      faculty.on_the_web.count > 0

    @has_affiliations = faculty.collaborators.count > 0 ||
      !faculty.affiliations_text.empty? ||
      faculty.appointments.count > 0 ||
      faculty.credentials.count > 0 ||
      faculty.training.count > 0

    @has_teaching = !faculty.teaching_overview.empty? ||
      faculty.teacher_for.count > 0

    @has_details = @has_publications || @has_research ||
      @has_background || @has_affiliations || @has_teaching
  end


  def get_publication_filters()
    pub_types = []
    faculty.contributor_to.each do |c|
      type = pub_types.find {|t| t[:id] == c.pub_type_id}
      if type == nil
        type = {id: c.pub_type_id, text: c.pub_type || "Other", count: 1}
        pub_types << type
      else
        type[:count] += 1
      end
    end
    pub_types
  end
end
