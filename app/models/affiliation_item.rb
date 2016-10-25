class AffiliationItem
  attr_accessor :uri, :name, :id
  def initialize(uri, name)
    @uri = uri
    @name = name
    @id = uri
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end
end
