class OrganizationController < ApplicationController
  def show
    id = params[:id]
    @presenter = DefaultPresenter.new()
    @organization = Organization.get_one(id)
  end

  def resolr
    solr_url = ENV["SOLR_URL"]
    solr = OrganizationSolrize.new(solr_url)
    id = params[:id]
    if solr.add_one(id)
      flash[:notice] = "Information for this organization has been updated"
      redirect_to display_show_url(id)
    else
      flash[:alert] = "Oops! could not refresh information for this organization (ID #{id})"
      redirect_to display_show_url(id), status: 500
    end
  end
end
