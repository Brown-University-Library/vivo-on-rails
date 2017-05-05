class Faculty2Controller < ApplicationController
  def index
    @faculty_list = Faculty.all()
  end

  def show
    id = params[:id]
    from_solr = true
    from_solr = false if params[:fuseki] == "true"
    faculty = Faculty.get_one(id, from_solr)
    @presenter = FacultyPresenter.new(faculty)
  end

  def resolr
    solr_url = ENV["SOLR_URL"]
    solr = FacultySolrize.new(solr_url)
    id = params[:id]
    if solr.add_one(id)
      redirect_to faculty_show_url(id)
    else
      render "error"
    end
  end
end
