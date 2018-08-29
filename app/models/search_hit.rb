class SearchHit
  attr_accessor :field, :value
  def initialize(field, value)
    @field = field
    @value = value
  end
end
