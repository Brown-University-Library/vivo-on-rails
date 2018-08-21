require "./app/models/model_utils.rb"
class SearchItem
  attr_accessor :vivo_id, :id, :uri, :name, :thumbnail, :type, :overview,
    :title, :email, :highlights

  def initialize(id, name, thumbnail, title, email, type, highlights)
    @id = id || ""
    @vivo_id = @id.split("/").last
    @uri = nil # set in the presenter
    @name = name
    @thumbnail = thumbnail
    @title = title
    @email = email
    @type = type
    @highlights = parse_highlights(highlights)
  end

  def self.from_hash(hash, record_type, thumbnail_url, highlights = nil)
    SearchItem.new(hash["id"], hash["name"], thumbnail_url, hash["title"],
      hash["email"], record_type, highlights)
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

  def parse_highlights(highlights)
    return [] if highlights == nil
    parsed = []
    highlights.keys.each do |key|
      item = {
        field: key,
        value: highlights[key].join(", ")
      }
      parsed << item
    end
    parsed
  rescue
    return []
  end

end
