require "./lib/solr_lite/explain_entry.rb"
module SolrLite
  class Explainer
    attr_accessor :entries
    # solr_response_hash is a JSON response from Solr converted to a hash
    # via JSON.parse()
    def initialize(solr_reponse_hash)
      @explain = solr_reponse_hash.fetch("debug", {}).fetch("explain", [])
      @entries = @explain.map do |ex|
        key = ex[0]
        text = ex[1]
        ExplainEntry.new(ex[0], ex[1])
      end
    end

    # Raw string with the explain information for each entry
    def text()
      text = ""
      @entries.each do |entry|
        text += "-- #{entry.key} {\r\n"
        text += "#{entry.text}\r\n"
        text += "}\r\n"
        text += "\r\n"
      end
      text
    end
  end
end
