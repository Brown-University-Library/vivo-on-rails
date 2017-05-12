class FacultyController < ApplicationController
  def show
    id = params[:id]
    from_solr = true
    from_solr = false if params[:fuseki] == "true"
    faculty = Faculty.get_one(id, from_solr)
    if faculty == nil
      flash[:alert] = "Researcher with ID #{id} was not found"
      render "error", status: 404
    else
      @presenter = FacultyPresenter.new(faculty)
    end
  end

  def resolr
    solr_url = ENV["SOLR_URL"]
    solr = FacultySolrize.new(solr_url)
    id = params[:id]
    if solr.add_one(id)
      flash[:notice] = "Information for this researcher has been updated"
      redirect_to faculty_show_url(id)
    else
      flash[:alert] = "Oops! could not refresh information for this researcher (ID #{id})"
      redirect_to faculty_show_url(id), status: 500
    end
  end
end
