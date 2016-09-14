class TrainingItem
  attr_accessor :school_uri, :date, :degree, :school_name
  def initialize(school_uri, date, degree, school_name)
    @school_uri = school_uri
    @date = date
    @degree = degree
    @school_name = school_name
  end
end
