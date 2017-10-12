# Handles fetching Organization information from Fuseki via SPARQL queries.
#
# This class was used then we protyped populating a separate Solr index
# with data from VIVO rather than using the built-in Solr index that
# VIVO manages.
#
# We don't use this class anymore but I am keeping it since it has the SPARQL
# queries with the predicates that we need to fetch the data.
# This class should be removed after we go live.
#
require "./lib/sparql/query.rb"
require "./app/models/json_utils.rb"
require "./app/models/organization_item.rb"
require "./app/models/organization_member_item.rb"
require "./app/models/on_the_web_item.rb"
class OrganizationFuseki

  MAX_ROW_LIMIT = "limit 10000"

  def self.all_uris
    # Run the following query to find out other variations
    # on how we represent organizations:
    #   select distinct ?type
    #   where {
    #     ?uri rdf:type foaf01:Organization .
    #     ?uri rdf:type ?type
    #   }
    sparql = <<-END_SPARQL
      select distinct ?uri
      where {
        ?uri rdf:type foaf01:Organization .
        ?uri rdf:type brown:BrownThing .
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
          ?uri rdf:type brown:BrownThing .
          optional {
            ?uri rdfs:label ?label .
            BIND(str(?label) as ?name) .
          }
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

  def self.get_one_from_fuseki(id)
    sparql = <<-END_SPARQL
      select ?uri ?name ?overview
      where {
        bind(individual:#{id} as ?uri) .
        ?uri rdf:type brown:BrownThing .
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
    organization.web_pages = get_web_pages(id)
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

  def self.get_web_pages(id)
    sparql = <<-END_SPARQL
    SELECT ?uri ?rank ?url ?text
    WHERE {
      individual:#{id} core:webpage ?uri .
      ?uri core:linkURI ?url .
      optional { ?uri core:linkAnchorText ?text . }
      optional { ?uri core:rank ?rank . }
    }
    END_SPARQL
    fuseki_url = ENV["FUSEKI_URL"]
    query = Sparql::Query.new(fuseki_url, sparql)
    web_pages = query.results.map { |row| OnTheWebItem.new(row) }
    web_pages.sort_by { |x| x.rank }
  end
end
