require "./app/models/model_utils.rb"
require "./app/models/date_utils.rb"
class AppointmentItem
  include ModelUtils

  attr_accessor :uri, :id
  attr_accessor :org_name       # e.g. "Harvard University"
  attr_accessor :name           # e.g. "Professor of the History of Medicine"
  attr_accessor :department     # e.g. "Department of the History of Medicine"
  attr_accessor :start_date     # e.g. 1993-04-23
  attr_accessor :end_date       # e.g. 1996-05-01

  def initialize(values)
    init_defaults()
    set_values_from_hash(values)
    @id = @uri
    @start_date = DateUtils.str_to_date(@start_date)
    @end_date = DateUtils.str_to_date(@end_date)
  end

  def init_defaults()
    @uri = ""
    @id = ""
    @org_name = ""
    @name = ""
    @department = ""
    @start_date = nil
    @end_date = nil
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end

  def year_range_str
    DateUtils.year_range_str(@start_date, @end_date)
  end
end
