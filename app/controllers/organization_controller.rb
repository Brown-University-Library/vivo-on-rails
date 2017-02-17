class OrganizationController < ApplicationController
  def index
  end

  def show
    id = params[:id]
    @presenter = DefaultPresenter.new()
    @organization = Organization.get_one(id)
  end
end
