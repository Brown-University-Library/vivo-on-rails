class EditController < ApplicationController
  # TODO enable session protection once they have been switched to HTTP POST

  def overview_update
    # TODO: call Steve's service to do the update
    result = {
        status: "ok",
        error: nil,
    }
    render :json => result
  end

  def research_area_update
    byebug
    url = ENV["EDIT_SERVICE"] + "/" + rabid(params[:id]) + "/faculty/edit/research/areas/update"
    Rails.logger.info(url)
    result = {
        status: "ok",
        error: nil,
    }
    render :json => result
  end

  def research_area_delete
    Rails.logger.info(url)
    url = ENV["EDIT_SERVICE"] + "/" + rabid(params[:id]) + "/faculty/edit/research/areas/delete"
    result = {
        status: "ok",
        error: nil,
    }
    render :json => result
  end

  def rabid(id)
    "http://vivo.brown.edu/individual/#{id}"
  end
end
