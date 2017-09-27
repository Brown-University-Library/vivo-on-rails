require "./app/models/model_utils.rb"
class OrganizationItem
  attr_accessor :id, :record_type, :uri, :name, :overview,
    :thumbnail, :people, :web_pages

  def initialize(values)
    init_defaults()
    ModelUtils.set_values_from_hash(self, values)
    @thumbnail = ModelUtils.safe_thumbnail(@thumbnail)
    @id = uri
  end

  def vivo_id
    return "" if @id == nil
    @id.split("/").last
  end

  def init_defaults()
    @record_type = "ORGANIZATION"
    @uri = ""
    @name = ""
    @overview = ""
    @thumbnail = nil
    @people = []
    @web_pages = []
  end

  def self.from_hash(hash)
    org = OrganizationItem.new(nil)
    hash.each do |key, value|
      getter = key.to_s
      case getter
      when "web_pages"
        org.web_pages = value.map { |v| OnTheWebItem.new(v) }
      when "people"
        org.people = value.map { |v| OrganizationMemberItem.new(v)}
      when "thumbnail"
        org.thumbnail = ModelUtils.safe_thumbnail(value)
      else
        setter = key.to_s + "="
        if org.respond_to?(setter)
          org.send(setter, value)
        else
          # we've got a value in Solr that we don't expect/want.
          Rails.logger.warn("Unexpected field #{key} received for organization #{hash['uri']}")
        end
      end
    end
    org
  end

end
