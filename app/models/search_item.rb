class SearchItem
  attr_accessor :vivo_id, :id, :uri, :name, :thumbnail, :type, :overview, :title, :email

  def initialize(vivo_id, id, name, thumbnail, title, email, type)
    @vivo_id = vivo_id
    @id = id
    @uri = nil # set in the presenter
    @name = name
    @thumbnail = thumbnail
    @title = title
    @email = email
    @type = type
  end

  def self.from_organization(org)
    SearchItem.new(org.vivo_id, org.id, org.name, org.thumbnail,
      nil, nil, "ORGANIZATION")
  end

  def self.from_person(person)
    SearchItem.new(person.vivo_id, person.id, person.name, person.thumbnail,
      person.title, person.email, "PEOPLE")
  end
end
