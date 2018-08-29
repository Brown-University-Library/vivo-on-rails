require "./app/models/model_utils.rb"
require "./app/models/search_hit.rb"

class SearchItem
  attr_accessor :vivo_id, :id, :uri, :name, :thumbnail, :type, :overview,
    :title, :email, :highlights

  HIGHLIGHTS_COUNT = 5

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

  # Returns the unique terms. Notice that it's case insensitive.
  #
  # For example if the highlights include:
  #     [
  #       "abc<strong>Value 1</strong>xyz",
  #       "abc<strong>Value 2</strong>xyz",
  #       "abc<strong>VALUE 1</strong>xyz"
  #     ]
  #
  # the returning value will be
  #     [
  #       "<strong>VALUE 1</strong>
  #       "<strong>VALUE 2</strong>"
  #     ]
  #
  def highlight_terms()
    terms = []
    @highlights.each do |hl|
      hl[:values].each do |snippet|
        # Notice that we use the lazy match (.*?) because the snippet
        # could contain multiple matches (e.g. on a multi-word search)
        hits = snippet.scan(/<strong>.*?<\/strong>/)
        hits.each do |hit|
          terms << hit.upcase
        end
      end
    end
    terms.uniq()
  end

  # Returns an array of SearchHits, one item per search term. For example
  # if the word "research" was found 3 times for a Solr document only the
  # first instance for it will be returned.
  def highlight_unique_values()
    values = []
    highlight_terms.each do |term|
      # For each unique term find the first instance of it in
      # the highlights and collect it
      @highlights.each do |hl|
        snippet = hl[:values].find {|value| value.upcase.include?(term) }
        if snippet != nil
          if values.find {|x| x.value == snippet} == nil
            values << SearchHit.new(hl[:field], snippet)
            break
          else
            # We already have this snippet, don't re-add it.
            # This prevents adding the same snippet twice because it
            # matched two different terms.
          end
        end
      end
    end
    values
  end

  # Returns all values for all the highlights, including duplicate hits.
  # For example if the word "research" was found 3 times, 3 results for it will
  # be returned.
  def highlight_all_values()
    values = []
    @highlights.each do |hl|
      hl[:values].each do |value|
        values << SearchHit.new(hl[:field], value)
      end
    end
    values
  end

  def highlights_values()
    values = highlight_unique_values()
    if values.count >= HIGHLIGHTS_COUNT
      # We got plenty of unique terms. We are done.
      return values
    end

    all = highlight_all_values()
    if values.count == all.count
      # We've got as much as we are going to get. We are done.
      return values
    end

    # We have less unique hits than the max allowed and we have more hits,
    # let's add a few more non-unique hits.
    all.each do |value|
      duplicate = values.find {|x| x.value == value.value} != nil
      if !duplicate
        values << value
        break if values.count >= HIGHLIGHTS_COUNT
      end
    end
    values
  end

  def highlights_html()
    html = ""
    values = highlights_values()
    values.each do |value|
      html += "<p>#{value.field}: #{value.value}</p>"
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
