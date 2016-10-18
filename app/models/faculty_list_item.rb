class FacultyListItem
  attr_accessor :id, :uri, :label, :title, :thumbnail
  def initialize(values = nil)
    set_values(values)
    @id = nil 
    if @uri != nil
      @id = @uri.split("/").last
    end
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
