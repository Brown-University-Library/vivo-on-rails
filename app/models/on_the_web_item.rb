require "./app/models/model_utils.rb"
class OnTheWebItem
  include ModelUtils

  attr_accessor :uri, :rank, :url, :text
  def initialize(values)
    set_values_from_hash(values)
    @id = @uri
    @rank = @rank.to_i
    @url = @url.strip               # link to the web page outside VIVO
    @text = (@text || @url).strip
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end
end
