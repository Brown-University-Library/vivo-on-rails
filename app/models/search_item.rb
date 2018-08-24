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

  # Returns the unique hits. Notice that it is case insensitive.
  #
  # For example if the highlights include:
  #     abc<strong>Value 1</strong>xyz
  #     abc<strong>Value 2</strong>xyz
  #     abc<strong>VALUE 1</strong>xyz
  #
  # the returning value will be
  #     ["<strong>VALUE 1</strong>, "<strong>VALUE 2</strong>"]
  #
  def highlights_unique_hits()
    values = []
    @highlights.each do |hl|
      hl[:values].each do |snippet|
        # The snippet should only contain one match but we still use the
        # lazy match (.*?) and account for multiple hits, just in case.
        hit = snippet.match(/<strong>.*?<\/strong>/)
        if hit != nil
          values << hit[0].upcase
        end
      end
    end
    values.uniq()
  end

  # Returns the first highlight for each of the unique hits. For example
  # if the word "research" was found 3 times only the first instace for it
  # will be returned.
  def highlights_values_unique()
    values = []
    # For each of the unique hits...
    unique_hits = highlights_unique_hits()
    unique_hits.each do |hit|
      # ...find the first value in the highlights for it and collect it
      @highlights.each do |hl|
        hit_value = hl[:values].find {|value| value.upcase.include?(hit) }
        if hit_value != nil
          if !values.include?(hit_value)
            values << hit_value
            break
          end
        end
      end
    end
    values
  end

  # Returns all values for all the highlights, including duplicate hits.
  # For example if the word "research" was found 3 times, 3 results for it will
  # be returned.
  def highlights_values_all()
    values = []
    @highlights.each do |hl|
      hl[:values].each do |value|
        values << value
      end
    end
    values
  end

  def highlights_values()
    unique = highlights_values_unique()
    if unique.count >= 5
      # We got plenty of unique terms. We are done.
      return unique
    end

    all = highlights_values_all()
    if unique.count == all.count
      # We've got as much as we are going to get. We are done.
      return unique
    end

    # Less than 5 unique hits but we have more hits,
    # let's add a few more non-unique hits.
    values = unique
    all.each do |value|
      if !values.include?(value)
        values << value
        break if values.count >= 5
      end
    end
    values
  end

  def highlights_html()
    html = ""
    values = highlights_values()
    values.each do |value|
      html += "<p>#{value}</p>"
    end

    # HTML encode problematic characters so that we can render text safely as HTML
    # (notice that we purposefuly preserve a few: <p>, <strong>)
    html.gsub!('<p>', '{p}')
    html.gsub!('</p>', '{/p}')
    html.gsub!('<strong>', '{strong}')
    html.gsub!('</strong>', '{/strong}')

    html.gsub!("'", '&#39;')
    html.gsub!('"', '&quot;')
    html.gsub!('<', '&lsaquo;')   # looks like < but it's ‹
    html.gsub!('>', '&rsaquo;')   # looks like > but it's ›

    html.gsub!('{p}', '<p>')
    html.gsub!('{/p}', '</p>')
    html.gsub!('{strong}', '<strong>')
    html.gsub!('{/strong}', '</strong>')

    # Remove the VIVO identifier from the text since it's meaningless to
    # the user.
    html.gsub!("Agent Faculty Member Organization or Person at Brown Person", "")

    html
  end

end
