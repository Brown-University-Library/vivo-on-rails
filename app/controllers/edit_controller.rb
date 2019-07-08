class EditController < ApplicationController
  # TODO enable session protection once
  skip_before_filter :authenticate_user!

  def overview_update
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    text = params[:text]
    error = FacultyEdit.overview_update(faculty_id, text)
    render_output(error)
  end

  def research_area_add
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    id = params[:id]
    error = FacultyEdit.research_area_add(faculty_id, id)
    render_output(error)
  end

  def research_area_delete
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    id = params[:id]
    error = FacultyEdit.research_area_delete(faculty_id, id)
    render_output(error)
  end

  private
    def render_output(error)
      if error == nil
        render :json => {status: 200, error: nil}
      else
        Rails.logger.error(error)
        render :json => {status: 400, error: error}
      end
    end
end
