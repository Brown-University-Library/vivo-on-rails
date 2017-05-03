require "./app/models/model_utils.rb"
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
    @start_date = str_to_date(@start_date)
    @end_date = str_to_date(@end_date)
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
    y1 = year_str(@start_date)
    y2 = year_str(@end_date)
    case
    when y1 && y2
      "#{y1}-#{y2}"
    when y1 && !y2
      "#{y1}"
    when !y1 && y2
      "#{y2}"
    else
      ""
    end
  end

  def str_to_date(str)
    begin
      # str is expected to be a in format YYYY-MM-DD
      Date.strptime(str)
    rescue
      nil
    end
  end

  private
    def year_str(date)
      return "" if date == nil
      return "Present" if date.year == 9999
      return date.year.to_s
    end
end
