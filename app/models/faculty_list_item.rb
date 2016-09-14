class FacultyListItem
  attr_reader :uri, :label, :title, :url, :thumbnail
  def initialize(uri, label, title, thumbnail)
    @uri = uri
    id = uri.split("/").last
    @url = url_for_item(id)
    @label = label
    @title = title
    @thumbnail = thumbnail
  end

  def url_for_item(id)
    # TODO: remove dependency on Rails
    Rails.application.routes.url_helpers.faculty_show_url(id: id)
  end
end
