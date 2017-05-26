class DateUtils
  def self.year_range_str(start_date, stop_date)
    y1 = year_str(start_date)
    y2 = year_str(stop_date)
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

  def self.str_to_date(str)
    begin
      # str is expected to be a in format YYYY-MM-DD
      Date.strptime(str)
    rescue
      nil
    end
  end

  def self.year_str(date)
    return "" if date == nil
    return "Present" if date.year == 9999
    return date.year.to_s
  end
end
