# This class is meant to represent _internal_ organizations at Brown
# (aka deparments). Not sure if we are also going to use it to handle
# external organizations (e.g. universities that our faculty graduated
# from).
require "./lib/sparql/query.rb"
require "./app/models/organization_item.rb"
require "./app/models/organization_member_item.rb"
class Organization

  MAX_ROW_LIMIT = "limit 10000"

  def self.all_uris
    # other possible filters are:
    #   ?uri rdf:type brown:BrownThing .
    #   ?uri rdf:type core:AcademicDepartment .
    sparql = <<-END_SPARQL
      select distinct ?uri
      where {
        ?uri rdf:type foaf01:Organization .
        ?uri rdf:type core:Department .
      }
      #{MAX_ROW_LIMIT}
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.results.map { |faculty| faculty[:uri] }
  end

  def self.get_batch(uris)
    results = []
    uris.each do |uri|
      # BIND(str(?label) as ?name) is to get a single
      # ?name value even if the label is in more than
      # one language.
      subject = "<#{uri}>"
      sparql = <<-END_SPARQL
        select distinct ?uri ?name ?overview
        where {
          bind(<#{uri}> as ?uri) .
          ?uri rdf:type core:Department .
          optional { ?uri rdfs:label ?label .
              BIND(str(?label) as ?name) .}
          optional { ?uri core:overview ?overview . }
        }
      END_SPARQL
      fuseki_url = ENV["FUSEKI_URL"]
      query = Sparql::Query.new(fuseki_url, sparql)
      if query.results.count > 0
        # TODO: WARN if more than one
        item = OrganizationItem.new(query.results.first)
        item.thumbnail = get_image(item.id)
        results << item
      end
    end
    results
  end

  def self.get_one(id)
    sparql = <<-END_SPARQL
      select ?uri ?name ?overview
      where {
        bind(individual:#{id} as ?uri) .
        ?uri rdf:type core:Department .
        optional { ?uri rdfs:label ?name . }
        optional { ?uri core:overview ?overview . }
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    result = query.results.first
    return nil if result == nil
    # What should we do if we get more than one?
    organization = OrganizationItem.new(result)
    organization.thumbnail = get_image(result[:uri])
    organization.people = get_people(result[:uri])
    organization
  end

  def self.get_image(uri)
    sparql = <<-END_SPARQL
      select ?image
      where {
        <#{uri}> vitro:mainImage ?thumbnail .
        ?thumbnail vitro:downloadLocation ?image .
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    query.to_value
  end

  def self.get_people(uri)
    # `fis_label` is the very specific label for person in the department
    # (e.g. "Associate Professor of Pathology and Laboratory Medicine")
    # where as `pos_label` is the general categorization for the position
    # (e.g. "Faculty Position")
    sparql = <<-END_SPARQL
      select ?uri ?fis_label ?pos_label ?person_label ?person ?pos ?fis
      where {
        bind(<#{uri}> as ?uri) .
        ?uri core:organizationForPosition ?fis .
        ?fis <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#mostSpecificType> ?pos .
        ?fis rdfs:label ?fis_label .
        ?pos rdfs:label ?pos_label .
        ?fis <http://vivoweb.org/ontology/core#positionForPerson> ?person .
        optional {
          ?person rdfs:label ?person_label .
        }
      }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    people = query.results.map do |row|
      item = OrganizationMemberItem.new()
      item.uri = row[:person]
      item.id = item.uri
      item.label = row[:person_label] || ""
      item.specific_position = row[:fis_label]
      item.general_position = row[:pos_label]
      item
    end
  end
end
