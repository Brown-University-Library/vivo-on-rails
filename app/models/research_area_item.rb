class ResearchAreaItem
  attr_accessor :label, :rabid, :vivo_id, :id

  def initialize(label, rabid)
    @label = label
    @rabid = rabid
    @vivo_id = ModelUtils::vivo_id(rabid)
    @id = vivo_id
  end

  def self.from_hash_array(array_values)
    values = array_values.map {|x| ResearchAreaItem.new(x["name"], x["rabid"])}
    sorted = values.sort_by {|x| (x.label || "").downcase}
    sorted
  end

  # A string array only gives us labels, no ids.
  def self.from_string_array(values)
    sorted = values.sort_by {|x| (x || "").downcase}
    sorted.map {|x| ResearchAreaItem.new(x,nil)}
  end
end
