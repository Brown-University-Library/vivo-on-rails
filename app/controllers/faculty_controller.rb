class FacultyController < ApplicationController
  def index
    @faculty_list = Faculty.all()
  end

  def show
    id = params[:id]
    @faculty = Faculty.get_one(id)
  end
end
