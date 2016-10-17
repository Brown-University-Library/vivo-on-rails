class OrganizationItem
  attr_accessor :uri, :name, :overview, :people, :parent

  def initialize(uri, name, overview)
    @uri = uri
    @name = name || ""
    @overview = overview || ""
  end
end
