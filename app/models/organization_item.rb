class OrganizationItem
  attr_accessor :record_type, :uri, :name, :overview, :thumbnail, :people

  def initialize(values)
    init_defaults()
    set_values(values)
  end

  def init_defaults()
    @record_type = "ORGANIZATION"
    @uri = ""
    @name = ""
    @overview = ""
    @thumbnail = ""
    @people = []
  end

  def id
    return "" if uri == nil
    uri.split("/").last
  end

  def set_values(hash)
    return if hash == nil
    hash.each do |key, value|
      setter = key.to_s + "="
      if self.respond_to?(setter)
        self.send(setter, value)
      end
    end
  end
end
