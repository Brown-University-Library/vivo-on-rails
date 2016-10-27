require "./app/models/model_utils.rb"
class AffiliationItem
  include ModelUtils

  attr_accessor :uri, :name, :id
  def initialize(values)
    init_defaults()
    set_values_from_hash(values)
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
end
