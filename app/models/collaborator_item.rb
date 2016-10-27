require "./app/models/model_utils.rb"
class CollaboratorItem
  include ModelUtils
  attr_accessor :uri, :name, :title

  def initialize(values)
    set_values_from_hash(values)
    @id = @uri
  end

  def short_id
    return "" if @id == nil
    @id.split("/").last
  end
end
