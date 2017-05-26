class FacultyController < ApplicationController
  def resolr
    solr_url = ENV["SOLR_URL"]
    solr = FacultySolrize.new(solr_url)
    id = params[:id]
    if solr.add_one(id)
      flash[:notice] = "Information for this researcher has been updated"
      redirect_to display_show_url(id)
    else
      flash[:alert] = "Oops! could not refresh information for this researcher (ID #{id})"
      redirect_to display_show_url(id), status: 500
    end
  end
end
