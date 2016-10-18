class OrganizationItem
  attr_accessor :uri, :name, :overview, :thumbnail
  # TODO: :people, :parent

  def initialize(uri, name, overview)
    @uri = uri
    @name = name || ""
    @overview = overview || ""
    @thumbnail = ""
  end
end
