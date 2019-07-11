class ResearchAreaItem
  attr_accessor :label, :rabid, :vivo_id, :id

  def initialize(label, rabid)
    @label = label
    @rabid = rabid
    @vivo_id = ModelUtils::vivo_id(rabid)
    @id = vivo_id
  end

  def self.from_hash_array(values)
    values.map {|v| ResearchAreaItem.new(v["label"], v["rabid"])}
  end

  # A string array only gives us labels, no ids.
  def self.from_string_array(values)
    sorted = values.sort_by {|a| (a || "").downcase}
    sorted.map {|v| ResearchAreaItem.new(v,nil)}
  end
end
