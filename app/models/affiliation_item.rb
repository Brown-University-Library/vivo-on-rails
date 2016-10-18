class AffiliationItem
  attr_accessor :uri, :name, :id
  def initialize(uri, name)
    @uri = uri
    @name = name
    @id = uri.split("/").last
  end
end
