require "./app/models/model_utils.rb"
class OnTheWebItem
  attr_accessor :uri, :rank, :url, :text

  def initialize(values)
    ModelUtils.set_values_from_hash(self, values)
    @id = @uri
    @rank = @rank.to_i
    @url = @url.strip               # link to the web page outside VIVO
    @text = (@text || @url).strip
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end

  def self.from_hash_array(values)
    values.map {|v| OnTheWebItem.new(v)}.sort_by {|v| v.rank}
  end

  def icon
    if @url.include?("/twitter.com/")
      return "twitter_logo.png"
    end
    if @url.include?("/www.facebook.com/")
      return "facebook_logo.png"
    end
    if @url.include?("/www.linkedin.com/")
      return "linkedin_logo.png"
    end
    if @url.include?("/www.researchgate.net/")
      return "researchgate_logo.png"
    end
    return nil
  end

end
