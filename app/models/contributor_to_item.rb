require "./app/models/model_utils.rb"
class ContributorToItem
  attr_accessor :uri, :authors, :title, :volume, :issue,
    :date, :pages, :published_in, :venue, :type, :doi, :pub_med_id,
    :external_url,
    :book, :location_label, :publisher_label, :editors

  attr_reader :year

  def initialize(values)
    ModelUtils.set_values_from_hash(self, values)
    @title = @title || ""
    @year = nil
    year = date.to_i
    if year >= 1900 && year <= 2200
      @year = year
    end
    @external_url = values["url"]
  end

  def pub_info
    info = ""
    publisher_info = publisher()
    if publisher_info != nil
      info += "#{publisher_info}. "
    end
    if @year != nil
      info += "#{@year}; "
    end
    if @volume != nil
      info += "#{@volume} "
    end
    if @issue != nil
      info += "(#{@issue}) "
    end
    if @pages != nil
      info += ": #{@pages}. "
    end
    info
  end

  def pub_info_book_section
    # Use MLA for book sections
    #
    # Last, First M. “Chapter Title.” Book/Anthology Title,
    # edited by First M. Last, Publisher, Year Published, page numbers
    # Website Title, URL.
    info = ""
    has_title = !@title.blank?
    has_book = !@book.blank?
    case
    when has_title && has_book
      info += "#{quote_title(@title)} <i>#{@book}</i>, "
    when has_title && !has_book
      info += "#{quote_title(@title)}, "
    when !has_title && has_book
      info += "<i>#{@book}</i>, "
    end

    if !@editors.blank?
      info = concat(info, "edited by #{@editors}", ",")
    end

    if !@location_label.blank?
      info = concat(info, "#{@location_label}", ",")
    end

    if !@publisher_label.blank?
      info = concat(info, @publisher_label, ",")
    end

    if !@year.blank?
      info = concat(info, @year.to_s, ",")
    end

    if !@pages.blank?
      info = concat(info, "pp. #{@pages}", ".")
    end

    add_period(info)
  end

  def pub_info_book
    # Use MLA for books
    info = ""
    has_title = !@title.blank?
    has_book = !@book.blank?
    case
    when has_title && has_book
      info += "<i>#{@title} #{@book}</i>."
    when has_title && !has_book
      info += "<i>#{@title}</i>."
    when !has_title && has_book
      info += "<i>#{@book}</i>."
    end

    if !@editors.blank?
      info = concat(info, "edited by #{@editors}", ",")
    end

    if !@location_label.blank?
      info = concat(info, "#{@location_label}", ",")
    end

    if !@publisher_label.blank?
      info = concat(info, @publisher_label, ",")
    end

    if !@year.blank?
      info = concat(info, @year.to_s, ".")
    end

    add_period(info)
  end

  def pub_info_article
    info = ""
    has_title = !@title.blank?
    has_book = !@book.blank?
    if !@title.blank?
      info += "#{quote_title(@title)} "
    end

    if !@venue.blank?
      info = concat(info, "<i>#{@venue}</i>", ",")
    end

    if @volume != nil
      info = concat(info, "vol. #{@volume}", ",")
    end

    if @issue != nil
      info = concat(info, "no. #{@issue}", ",")
    end

    if !@year.blank?
      info = concat(info, @year.to_s, ",")
    end

    if !@pages.blank?
      info = concat(info, "pp. #{@pages}", ".")
    end

    add_period(info)
  end

  def concat(value, value2, delimiter)
    value2 = (value2 || "").strip
    if value2.blank?
      return value
    end

    new_value = "#{value} #{value2}"
    if !new_value.end_with?(delimiter)
      new_value += delimiter
    end
    new_value
  end

  def quote_title(value)
    value = (value || "").strip

    # Drop fancy quotes (if present)
    if value.start_with?("“")
      value = value[1..-1]
    end
    if value.end_with?("”")
      value = value[0..-1]
    end

    # Add normal quotes (if not present)
    if value[0] != '"'
      value = '"' + value
    end
    if value[-1] != '"'
      value = value + '"'
    end

    # Make sure the text ends in a period e.g. "hello."
    if value[-2] != '.'
      value = value[0..-2] + '."'
    end
    value
  end

  def add_period(text)
    value = text.strip
    if value.end_with?(".")
      return value
    elsif value.end_with?(",")
      return value[0..-2] + "."
    end
    return value + "."
  end

  def doi_url
    return nil if @doi == nil
    "https://doi.org/#{@doi}"
  end

  def pub_med_url
    return nil if @pub_med_id == nil
    "http://www.ncbi.nlm.nih.gov/pubmed/?term=#{@pub_med_id}"
  end

  def bdr_url
    if @external_url == nil || !@external_url.start_with?("https://repository.library.brown.edu")
      return nil
    end
    @external_url
  end

  def full_text_url
    if bdr_url != nil
      # Give preference to the BDR URL
      # since it's more likely to be open access.
      bdr_url
    elsif doi_url != nil
      doi_url
    else
      nil
    end
  end

  def more_info_url
    if pub_med_url != nil || full_text_url != nil
      nil
    else
      @external_url
    end
  end

  def pub_type
    # Typical @type values:
    #   citation:Abstract
    #   citation:Article
    #   citation:Book
    #   citation:BookSection
    #   citation:Citation
    #   citation:Conference
    #   citation:ConferenceLocation
    #   citation:ConferencePaper
    #   citation:Contributor
    #   citation:Location
    #   citation:Patent
    #   citation:Publisher
    #   citation:Review
    #   citation:Venue
    #   citation:WorkingPaper
    citationPrefix = "http://vivo.brown.edu/ontology/citation#"
    return nil if @type == nil
    return nil if !@type.start_with?(citationPrefix)
    type = @type.gsub(citationPrefix,"")
    if type == "Citation"
      type = "Other"
    end
    type = type.gsub(/[A-Z]/, ' \0') # adds space between words
    return type
  end

  def pub_type_id
    return nil if pub_type == nil
    pub_type.downcase.gsub(" ","_")
  end

  def self.from_hash_array(values)
    values.map {|v| ContributorToItem.new(v)}.sort
  end

  # Custom sorting of publications (descending by year, ascending by title)
  #
  # Notice that we use the year and not the full date of publication. This is
  # probably becase we don't display the full date of publication and without
  # it it's confusing for users to figure out why a publication shows before
  # another from the same year. Plus, I am not sure our "date of publication"
  # values are very accurate (e.g. most of them say have month "01", day "01").
  def <=>(other)
    year1 = (self.year || 0)
    year2 = (other.year || 0)
    if year1 == year2
      # ascending by title
      title1 = (self.title || "").strip.downcase
      title2 = (other.title || "").strip.downcase
      return title1 <=> title2
    else
      # descending by year
      if year1 > year2
        return -1
      else
        return 1
      end
    end
  end

  private
    def publisher
      case
      when @published_in == nil && @venue == nil
        nil
      when @published_in == nil && @venue != nil
        @venue
      when @published_in != nil && @venue == nil
        @published_in
      else
        @published_in + "/" +  @venue
      end
    end
end
