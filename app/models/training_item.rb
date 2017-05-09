require "./app/models/model_utils.rb"
require "./app/models/date_utils.rb"
class TrainingItem
  include ModelUtils

  attr_accessor :name, :start_date, :end_date,
    :city, :state, :country,
    :org_name, :hospital_name, :specialty_name
  def initialize(values)
    set_values_from_hash(values)
    @start_date = DateUtils.str_to_date(@start_date)
    @end_date = DateUtils.str_to_date(@end_date)
  end

  def year_range_str
    DateUtils.year_range_str(@start_date, @end_date)
  end

  def org_full_name
    [@org_name, @hospital_name, @specialty_name].compact.join(", ")
  end

  def location
    [@city, @state, @country].compact.join(", ")
  end
end
