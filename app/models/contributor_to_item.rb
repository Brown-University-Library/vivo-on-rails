require "./app/models/model_utils.rb"
class ContributorToItem
  include ModelUtils # needed for set_values_from_hash

  attr_accessor :uri, :authors, :title, :volume, :issue,
    :date, :pages, :published_in, :venue_name

  def initialize(values)
    set_values_from_hash(values)
    @year = nil
    year = date.to_i
    if year >= 1900 && year <= 2200
      @year = year
    end
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

  private
    def publisher
      case
      when @published_in == nil && @venue_name == nil
        nil
      when @published_in == nil && @venue_name != nil
        @venue_name
      when @published_in != nil && @venue_name == nil
        @published_in
      else
        @published_in + "/" +  @venue_name
      end
    end
end
