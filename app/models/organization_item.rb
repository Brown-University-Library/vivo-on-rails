require "./app/models/model_utils.rb"
class OrganizationItem
  include ModelUtils

  attr_accessor :record_type, :uri, :name, :overview, :thumbnail, :people
  attr_reader :id

  def initialize(values)
    init_defaults()
    set_values_from_hash(values)
    @id = uri
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end

  def init_defaults()
    @record_type = "ORGANIZATION"
    @uri = ""
    @name = ""
    @overview = ""
    @thumbnail = ""
    @people = []
  end
end
