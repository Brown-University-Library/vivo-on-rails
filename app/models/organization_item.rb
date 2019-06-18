require "./app/models/model_utils.rb"
class OrganizationItem
  attr_accessor :id, :record_type, :uri, :name, :overview,
    :thumbnail, :people, :web_pages

  def initialize(values)
    init_defaults()
    ModelUtils.set_values_from_hash(self, values)
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
    @thumbnail = ""
    @people = []
    @web_pages = []
  end

  def is_team?
    @record_type == "TEAM"
  end

  def self.from_hash(hash, thumbnail_url)
    org = OrganizationItem.new(nil)
    org.thumbnail = thumbnail_url
    hash.each do |key, value|
      begin
        getter = key.to_s
        case getter
        when "web_pages"
          org.web_pages = value.map { |v| OnTheWebItem.new(v) }
        when "people"
          org.people = OrganizationMemberItem.from_hash_array(value)
        when "thumbnail"
          # Ignore this value, we use thumbnail_url parameter instead
        else
          setter = key.to_s + "="
          if org.respond_to?(setter)
            org.send(setter, value)
          else
            # we've got a value in Solr that we don't expect/want.
            Rails.logger.warn("Unexpected field #{key} received for organization #{hash['uri']}")
          end
        end
      rescue => ex
        backtrace = ex.backtrace.join("\r\n")
        Rails.logger.error("Error parsing data for Organization: #{hash['uri']}. Exception: #{ex} \r\n #{backtrace}")
      end
    end
    org
  end

end
