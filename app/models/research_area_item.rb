class ResearchAreaItem
  attr_accessor :label, :rabid, :vivo_id

  def initialize(label, rabid)
    @label = label
    @rabid = rabid
    @vivo_id = ModelUtils::vivo_id(rabid)
  end

  def self.from_hash_array(values)
    values.map {|v| ResearchAreaItem.new(v["label"], v["rabid"])}
  end
end
