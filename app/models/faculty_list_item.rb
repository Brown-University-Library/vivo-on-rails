class FacultyListItem
  attr_reader :id, :uri, :label, :title, :thumbnail
  def initialize(uri, label, title, thumbnail)
    @uri = uri
    @id = uri.split("/").last
    @label = label
    @title = title
    @thumbnail = thumbnail
  end
end
