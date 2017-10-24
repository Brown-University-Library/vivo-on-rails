require "./app/models/model_utils.rb"
class SearchItem
  attr_accessor :vivo_id, :id, :uri, :name, :thumbnail, :type, :overview, :title, :email

  def initialize(id, name, thumbnail, title, email, type)
    @id = id || ""
    @vivo_id = @id.split("/").last
    @uri = nil # set in the presenter
    @name = name
    @thumbnail = thumbnail
    @title = title
    @email = email
    @type = type
  end

  def self.from_hash(hash, record_type, thumbnail_path)
    thumbnail_url = ModelUtils.thumbnail_url(thumbnail_path)
    SearchItem.new(hash["id"], hash["name"], thumbnail_url, hash["title"],
      hash["email"], record_type)
  end

  def type_schema_org()
    if @type == "PEOPLE"
      "http://schema.org/Person"
    elsif @type == "ORGANIZATION"
      "http://schema.org/Organization"
    else
      nil
    end
  end
end
