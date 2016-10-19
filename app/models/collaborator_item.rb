class CollaboratorItem
  attr_accessor :uri, :name, :title

  def initialize(uri, name, title)
    @uri = uri
    @name = name
    @title = title
  end

  def id
    return "" if @uri == nil
    uri.split("/").last
  end
end
