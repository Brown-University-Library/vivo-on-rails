require "./app/models/model_utils.rb"
class ContributorToItem
  include ModelUtils

  attr_accessor :uri, :authors, :title, :volume, :issue,
    :date, :pages, :published_in

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
    if @published_in != nil
      info += "#{@published_in}. "
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
end
