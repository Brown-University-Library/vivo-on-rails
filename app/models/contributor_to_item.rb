class ContributorToItem
  attr_accessor :uri, :authors, :title
  def initialize(uri, authors, title)
    @uri = uri
    @authors = authors
    @title = title
  end
end
