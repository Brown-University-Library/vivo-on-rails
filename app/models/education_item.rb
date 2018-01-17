require "./app/models/model_utils.rb"
class EducationItem

  attr_accessor :school_uri, :date, :degree, :school_name
  def initialize(values)
    ModelUtils.set_values_from_hash(self, values)
    if @school_name != nil
      @school_name = @school_name.strip
    end
  end

  def self.from_hash_array(values)
    # date is really just a year (e.g. "1999") and therefore OK to compare with ""
    values.map {|v| EducationItem.new(v)}.sort_by {|v| v.date || ""}.reverse
  end
end
