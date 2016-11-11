class FacultyController < ApplicationController
  def index
    @faculty_list = Faculty.all()
  end

  def show
    id = params[:id]
    from_solr = true
    from_solr = false if params[:fuseki] == "true"
    @faculty = Faculty.get_one(id, from_solr)
    @faculty
  end
end
