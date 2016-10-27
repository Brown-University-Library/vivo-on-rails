require "./app/models/model_utils.rb"
class OrganizationItem
  include ModelUtils

  attr_accessor :id, :record_type, :uri, :name, :overview, :thumbnail, :people

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

  def self.from_hash(hash)
    org = OrganizationItem.new(nil)
    hash.each do |key, value|
      getter = key.to_s
      case getter
      when "people"
        org.people = value.map {|v| OrganizationMemberItem.new(v)}
      else
        setter = key.to_s + "="
        org.send(setter, value)
      end
    end
    org
  end

end
