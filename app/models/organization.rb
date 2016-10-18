require "./lib/sparql/query.rb"
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
  end
end
