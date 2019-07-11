require "./app/models/model_utils.rb"
class AffiliationItem
  attr_accessor :uri, :name, :id
  def initialize(values)
    init_defaults()
    ModelUtils.set_values_from_hash(self, values)
    @id = @uri
    @thumbnail = nil
  end

  def init_defaults()
    @uri = ""
    @name = ""
    @id = ""
  end

  def vivo_id
    ModelUtils::vivo_id(@id)
  end

  def self.from_hash_array(values)
    values.map {|v| AffiliationItem.new(v)}.sort_by {|v| (v.name || "").downcase}
  end

  def thumbnail
    @thumbnail ||= begin
      org = Organization.load_from_solr(vivo_id)
      if org == nil
        "org_placeholder.png"
      else
        org.item.thumbnail || "org_placeholder.png"
      end
    rescue
      "org_placeholder.png"
    end
  end
end
