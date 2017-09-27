require "./app/models/model_utils.rb"
class CollaboratorItem
  attr_accessor :uri, :name, :title

  def initialize(values)
    ModelUtils.set_values_from_hash(self, values)
    @id = @uri
  end

  def short_id
    return "" if @id == nil
    @id.split("/").last
  end

  def self.from_hash_array(values)
    values.map {|v| CollaboratorItem.new(v)}.sort_by {|v| (v.name || "").downcase}
  end
end
