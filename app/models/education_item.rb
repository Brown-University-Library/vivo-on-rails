require "./app/models/model_utils.rb"
class EducationItem

  attr_accessor :school_uri, :date, :degree, :school_name
  def initialize(values)
    ModelUtils.set_values_from_hash(self, values)
  end
end
