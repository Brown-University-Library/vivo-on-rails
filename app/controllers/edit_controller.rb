class EditController < ApplicationController
  def overview
    params[""]
    result = {
        status: "ok",
        error: nil,
    }
    render :json => result
  end
end
