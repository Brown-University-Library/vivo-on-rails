require "./app/models/model_utils.rb"
require "./app/models/date_utils.rb"
class CredentialItem
  attr_accessor :uri, :id
  attr_accessor :name           # e.g. CSR-Allopathic Physician (MD)
  attr_accessor :number         # e.g. #MD11676
  attr_accessor :start_date     # e.g. 1993-04-23
  attr_accessor :end_date       # e.g. 1996-05-01
  attr_accessor :grantor_name   # e.g. ABIM
  attr_accessor :specialty_name # e.g. internal medicine

  def initialize(values)
    init_defaults()
    ModelUtils.set_values_from_hash(self, values)
    @id = @uri
    @start_date = DateUtils.str_to_date(@start_date)
    @end_date = DateUtils.str_to_date(@end_date)
  end

  def self.from_hash_array(values)
    values.map {|v| CredentialItem.new(v)}.sort_by {|v| v.start_date || Date.new(1900,1,1)}.reverse
  end

  def init_defaults()
    @uri = ""
    @id = ""
    @name = ""
    @number = ""
    @start_date = nil
    @end_date = nil
    @grantor_name = ""
    @specialty_name = ""
  end

  def number_display
    return "" if @number.empty?
    "#" + @number
  end

  def grantor_display
    a = capitalize_first(@grantor_name)
    b = capitalize_first(@specialty_name)
    case
    when a != "" && b != ""
      a + ", " + b
    when a != "" && b == ""
      a
    when a == "" && b != ""
      b
    else
      ""
    end
  end

  def capitalize_first(str)
    if str == nil || str.length == 0
      return ""
    end
    str[0].capitalize + str[1..-1]
  end

  def vivo_id
    ModelUtils::vivo_id(@id)
  end

  def year_range_str
    DateUtils.year_range_str(@start_date, @end_date)
  end
end
