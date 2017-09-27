require "./app/models/model_utils.rb"
class AffiliationItem
  attr_accessor :uri, :name, :id
  def initialize(values)
    init_defaults()
    ModelUtils.set_values_from_hash(self, values)
    @id = @uri
  end

  def init_defaults()
    @uri = ""
    @name = ""
    @id = ""
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end

  def self.from_hash_array(values)
    values.map {|v| AffiliationItem.new(v)}.sort_by {|v| (v.name || "").downcase}
  end
end
