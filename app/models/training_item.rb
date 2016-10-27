require "./app/models/model_utils.rb"
class TrainingItem
  include ModelUtils

  attr_accessor :school_uri, :date, :degree, :school_name
  def initialize(values)
    set_values_from_hash(values)
  end
end
