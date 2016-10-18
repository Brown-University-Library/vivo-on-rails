require "./lib/sparql/query.rb"
require "./app/models/organization_item.rb"
require "./app/models/faculty_list_item.rb"
class Organization

  def self.all
    [1, 2, 3]
  end

  def self.get_one(id)
    sparql = <<-END_SPARQL
      select ?uri ?name ?overview
      where {
        bind(individual:#{id} as ?uri) .
        ?uri rdf:type foaf01:Organization .
        optional { ?uri rdfs:label ?name . }
        optional { ?uri core:overview ?overview . }
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    result = query.results.first
    return nil if result == nil
    # What should we do if we get more than one?
    organization = OrganizationItem.new(result[:uri], result[:name], result[:overview])
    organization.thumbnail = get_image(id)
    organization.people = get_people(id)
    organization
  end

  def self.get_image(id)
    sparql = <<-END_SPARQL
      select ?image
      where {
        individual:#{id} vitro:mainImage ?thumbnail .
        ?thumbnail vitro:downloadLocation ?image .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.to_value
  end

  def self.get_people(id)
    sparql = <<-END_SPARQL
      select ?fis_label ?pos_label ?person_label ?person ?pos ?fis 
      where {
        individual:#{id} core:organizationForPosition ?fis .
        optional {
          ?fis rdfs:label ?fis_label .
          ?fis <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#mostSpecificType> ?pos .
          ?pos rdfs:label ?pos_label .
          ?fis <http://vivoweb.org/ontology/core#positionForPerson> ?person .
          ?person rdfs:label ?person_label .
        }
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map do |row|
      item = FacultyListItem.new()
      item.uri = row[:person]
      if item.uri
        item.id = item.uri.split("/").last
      end
      item.label = row[:person_label]
      item.title  = row[:fis_label]
      # item.pos_label = row[:pos_label]
      item
    end
  end
end
