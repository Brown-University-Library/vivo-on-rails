class OrganizationController < ApplicationController
  def index
  end

  def show
    id = params[:id]
    @organization = Organization.get_one(id)
  end
end
