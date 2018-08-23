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
        values: highlights[key].map {|value| value.strip}
      }
      parsed << item
    end
    parsed
  rescue
    return []
  end

  def highlights_html()
    html = ""
    @highlights.each do |hl|
      html += "<p>"
      html += hl[:values].join("...<br/>")
      html += "</p>"
    end

    # HTML encode problematic characters so that we can render text safely as HTML
    # (notice that we purposefuly preserve a few: <p>, <strong>, and <br/>)
    html.gsub!('<p>', '{p}')
    html.gsub!('</p>', '{/p}')
    html.gsub!('<strong>', '{strong}')
    html.gsub!('</strong>', '{/strong}')
    html.gsub!('<br/>', '{br/}')

    html.gsub!("'", '&#39;')
    html.gsub!('"', '&quot;')
    html.gsub!('<', '&lsaquo;')   # looks like < but it's ‹
    html.gsub!('>', '&rsaquo;')   # looks like > but it's ›

    html.gsub!('{strong}', '<strong>')
    html.gsub!('{/strong}', '</strong>')
    html.gsub!('{br/}', '<br/>')
    html.gsub!('{p}', '<p>')
    html.gsub!('{/p}', '</p>')

    # Remove the VIVO identifier from the text since it's meaningless to
    # the user.
    html.gsub!("Agent Faculty Member Organization or Person at Brown Person", "")

    html
  end

end
