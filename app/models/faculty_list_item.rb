class FacultyListItem
  attr_reader :uri, :label, :title, :url, :thumbnail
  def initialize(uri, label, title, thumbnail)
    @uri = uri
    @url = "/faculty/" + uri.split("/").last
    @label = label
    @title = title
    @thumbnail = thumbnail
  end
end
