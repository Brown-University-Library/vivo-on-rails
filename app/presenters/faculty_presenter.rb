class FacultyPresenter
  attr_accessor :query, :form_values, :user
  attr_accessor :faculty, :has_publications, :has_research, :has_background,
    :has_affiliations, :has_teaching, :has_details,
    :publication_filters,
    :show_back_to_search, :show_visualizations, :has_coauthors, :has_collaborators,
    :edit_mode


  def initialize(faculty, search_url, referer, force_show_viz, edit_mode = false)
    @edit_mode = edit_mode
    @faculty = faculty

    # Show it only if we are coming to the faculty page from a search
    @show_back_to_search = referer && referer.start_with?(search_url)

    # These flags are used for deciding if we need to render the visualizations.
    #
    #   show_visualizations:  true if user has turned on visualizations.
    #   has_coauthors:        true if there are coauthors for this researcher.
    #   has_collaborators:    true if there are collaboators for this researcher.
    #
    # Notice that the has_coauthors and has_collaborators flags represent
    # whether the corresponding network for the researcher has been calculated
    # and contains data (i.e. it not just depending on a simple count of
    # publications or collaborators).
    #
    @show_visualizations = @faculty.show_visualizations || force_show_viz
    @has_coauthors = @faculty.has_coauthors
    @has_collaborators = @faculty.has_collaborators

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

  # TODO: we should get the research area IDs from VIVO rather than trying to
  # calculate them.
  def research_area_id(research_area)
    research_area.gsub(" ", "_")
  end
end
