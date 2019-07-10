require "./app/models/fast_service.rb"

class EditController < ApplicationController
  # TODO enable session protection once
  skip_before_filter :authenticate_user!

  def fast_search
    results = []
    text = (params[:text] || "").strip
    if (text.length >= 3)
      results = FastService.search(text, true)
    end
    render :json => {status: 200, data: results}
  end

  def overview_update
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    text = params[:text]
    error = FacultyEdit.overview_update(faculty_id, text)
    render_output(nil, error)
  end

  def research_area_add
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    text = params[:text]
    id, error = FacultyEdit.research_area_add(faculty_id, text)
    render_output({id: id}, error)
  end

  def research_area_delete
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    id = params[:id]
    error = FacultyEdit.research_area_delete(faculty_id, id)
    render_output(nil, error)
  end

  private
    def render_output(data, error)
      if error != nil
        Rails.logger.error(error)
        render :json => {error: error}, status: 400
      else
        render :json => data || {}, status: 200
      end
    end
end
