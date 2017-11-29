require "./lib/solr_lite/explain_entry.rb"
module SolrLite
  class Explainer
    attr_accessor :entries

    # solr_response_hash a Solr HTTP response parsed via JSON.parse()
    def initialize(solr_reponse_hash)
      @explain = solr_reponse_hash.fetch("debug", {}).fetch("explain", [])
      @entries = @explain.map do |ex|
        key = ex[0]
        text = ex[1]
        ExplainEntry.new(ex[0], ex[1])
      end
    end

    # solr_response (string) is the Solr HTTP response from a query
    def self.from_response(solr_response)
      hash = JSON.parse(solr_response)
      Explainer.new(hash)
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
