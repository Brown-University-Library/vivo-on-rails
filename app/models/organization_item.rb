require "./app/models/model_utils.rb"
class OrganizationItem
  attr_accessor :id, :record_type, :uri, :name, :overview,
    :thumbnail, :people, :web_pages, :faculty

  def initialize(values)
    init_defaults()
    ModelUtils.set_values_from_hash(self, values)
    @id = uri
  end

  def vivo_id
    ModelUtils::vivo_id(@id)
  end

  def init_defaults()
    @record_type = "ORGANIZATION"
    @uri = ""
    @name = ""
    @overview = ""
    @thumbnail = ""
    @people = []      # Array of OrganizationMemberItem
    @faculty = []     # Array of Faculty
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

  def add_custom_members(faculty_ids)
    members = []

    faculty_docs = Faculty.load_from_solr_many(faculty_ids)
    faculty_docs.each do |faculty|
      member = {
        id: ModelUtils::vivo_id(faculty.item.id),
        faculty_uri: faculty.item.id,
        label: faculty.item.name,
        general_position: "general position",
        specific_position: faculty.item.title
      }
      if @people.find {|x| x.vivo_id == member[:id]} == nil
        @people << OrganizationMemberItem.new(member)
      end
    end

    @people.sort_by! {|x| x.label}
  end
end
