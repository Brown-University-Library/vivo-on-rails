require "./app/models/model_utils.rb"
class SearchItem
  attr_accessor :vivo_id, :id, :uri, :name, :thumbnail, :type, :overview, :title, :email

  def initialize(id, name, thumbnail, title, email, type)
    @id = id || ""
    @vivo_id = @id.split("/").last
    @uri = nil # set in the presenter
    @name = name
    @thumbnail = ModelUtils.safe_thumbnail(thumbnail)
    @title = title
    @email = email
    @type = type
  end

  def self.from_hash(hash, record_type)
    SearchItem.new(hash["id"], hash["name"], hash["thumbnail"], hash["title"],
      hash["email"], record_type)
  end
end
