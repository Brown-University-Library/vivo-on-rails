module SolrLite
  class Explainer

    # TODO: Create an structure to represent this data in addition
    # to the text representations that we provide via text(), match(),
    # topmatch(), and scores()
    def initialize(solr_reponse_hash)
      @explain = solr_reponse_hash.fetch("debug", {}).fetch("explain", [])
    end

    # The raw string with the explain information
    # (but we remove the extra linebreak that Solr includes)
    def text()
      text = ""
      @explain.each do |r|
        key = r[0]
        explain = r[1]
        fixed = explain.gsub("\n), product of:", ", product of:")
        text += "-- #{key} {\r\n"
        text += "#{fixed}\r\n"
        text += "}\r\n"
        text += "\r\n"
      end
      text
    end

    # A string with the results but only include the match for the field
    # that was picked in the scoring.
    def topmatch()
      text = ""
      @explain.each do |r|
        key = r[0]
        explain = r[1]
        lines = explain.split("\n")
        matches = lines.select {|l| l.include?("(MATCH)") || l.include?("coord(")}

        text += "#{key} {\r\n"
        score = nil
        matches.each do |line|
          if line.include?("max of")
              score = line.strip.split().first
              next
          end

          if score == nil
            text += "#{line}\r\n"
          else
            if line.strip.start_with?(score)
              text += "#{line}\r\n"
            else
              if line.include?("coord(")
                text += "#{line}\r\n"
              end
            end
          end
        end
        text += "}\r\n"
        text += "\r\n"
      end
      text
    end

    # A string with the results including ALL matches that were evaluated
    # in the scoring.
    def matches()
      text = ""
      @explain.each do |r|
        key = r[0]
        explain = r[1]
        lines = explain.split("\n")
        matches = lines.select {|l| l.include?("(MATCH)") || l.include?("coord(")}
        text += "#{key} {\r\n"
        matches.each do |line|
          text += "#{line}\r\n"
        end
        text += "}\r\n"
        text += "\r\n"
      end
      text
    end

    # A string with the results and their scoring (no matching information
    # is included). One line per result.
    def scores()
      text = ""
      max_key_element = @explain.max {|x,y| x[0].length <=> y[0].length }
      max_key_length = max_key_element[0].length
      @explain.each do |r|
        key = r[0]
        explain = r[1]
        lines = explain.split("\n")
        matches = lines.select {|l| l.include?("(MATCH)") }
        key_padded = key.ljust(max_key_length)
        text += "#{key_padded}\t#{matches[0]}\r\n"
      end
      text
    end
  end
end
