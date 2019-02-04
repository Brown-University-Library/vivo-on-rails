require "./app/models/model_utils.rb"
require "./app/models/search_highlights.rb"

class SearchItem
  attr_accessor :vivo_id, :id, :uri, :name, :thumbnail, :type, :overview,
    :title, :email, :highlights

  def initialize(id, name, thumbnail, title, email, type, solr_doc_highlights)
    @id = id || ""
    @vivo_id = @id.split("/").last
    @uri = nil # set in the presenter
    @name = name
    @thumbnail = thumbnail
    @title = title
    @email = email
    @type = type
    @highlights = SearchHighlights.new(solr_doc_highlights)
  end

  def self.from_hash(hash, record_type, thumbnail_url, highlights = nil)
    name = hash["name"]
    if hash["display_name_s"] != nil
      # If we have a display name use that one.
      name = hash["display_name_s"]
    end

    SearchItem.new(hash["id"], name, thumbnail_url, hash["title"],
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
end
