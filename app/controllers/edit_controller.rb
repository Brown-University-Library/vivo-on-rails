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
    text, error = FacultyEdit.simple_text_update("overview/overview/update", faculty_id, text, "overview")
    render_output({text: text}, error)
  end

  def research_area_add
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    text = params[:text]
    rab_id, error = FacultyEdit.research_area_add(faculty_id, text)
    render_output({id: ModelUtils::vivo_id(rab_id)}, error)
  end

  def research_area_delete
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    id = params[:id]
    _, error = FacultyEdit.research_area_delete(faculty_id, id)
    render_output(nil, error)
  end

  def web_link_save
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    text = params[:text]
    url = params[:url]
    rank = params[:rank]
    id = params[:id]
    rab_id, error = FacultyEdit.web_link_save(faculty_id, text, url, rank, id)
    data = {
      id: ModelUtils::vivo_id(rab_id),
      text: text,
      url: url,
      rank: rank
    }
    render_output(data, error)
  end

  def web_link_delete
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    id = params[:id]
    _, error = FacultyEdit.web_link_delete(faculty_id, id)
    render_output(nil, error)
  end

  def research_overview_update
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    text = params[:text]
    text, error = FacultyEdit.simple_text_update("research/overview/update", faculty_id, text, "research_overview")
    render_output({text: text}, error)
  end

  def research_statement_update
    return if ENV["EDIT_ALLOWED"] != "true"
    faculty_id = params[:faculty_id]
    text = params[:text]
    text, error = FacultyEdit.simple_text_update("research/statement/update", faculty_id, text, "research_statement")
    render_output({text: text}, error)
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
