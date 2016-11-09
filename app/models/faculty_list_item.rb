require "./app/models/model_utils.rb"
class FacultyListItem
  include ModelUtils

  attr_accessor :id, :uri, :name, :title, :thumbnail, :email
  def initialize(values = nil)
    set_values_from_hash(values)
    @id = @uri
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end
end
