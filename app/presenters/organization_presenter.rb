class OrganizationPresenter
  attr_accessor :query, :form_values
  attr_accessor :organization, :show_back_to_search,
    :faculty_positions, :admin_positions, :all_positions

  def initialize(organization, search_url, referer)
    @organization = organization

    # Show it only if we are coming to the faculty page from a search
    @show_back_to_search = referer && referer.start_with?(search_url)

    @all_positions = @organization.people
    @admin_positions = @organization.people.select {|x| x.admin_position? }
    @faculty_positions = @organization.people.select {|x| x.admin_position? == false }
  end
end
