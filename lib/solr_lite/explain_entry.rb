module SolrLite
  class ExplainEntry
    attr_accessor :key, :score, :matches, :top_matches, :text

    def initialize(key, text)
      @key = key
      # get rid of this one extraneous linebreak that Solr includes
      @text = text.gsub("\n), product of:", ", product of:")
      @matches = get_matches(@text)
      @score = @matches.first.split(" ").first
      @top_matches = get_top_matches(@matches)
    end

    private
      # For a given entry, returns an array with the lines that include match
      # information (notice that we also include line with the coord() value)
      def get_matches(text)
        lines = text.split("\n")
        lines.select {|l| l.include?("(MATCH)") || l.include?("coord(")}
      end

      # A subset of the matches that includes only the match that was picked
      # i.e. the one with the higher score.
      # (notice that we also include line with the coord() value)
      def get_top_matches(matches)
        top = []
        token_score = nil
        matches.each do |line|
          if line.include?("max of")
            token_score = line.strip.split().first
          else
            if token_score == nil
              # If we don't have a score to match this line is probably a
              # "product of" or "sum of" marker. Include it.
              top << line
            else
              if line.strip.start_with?(token_score)
                top << line
              elsif line.include?("coord(")
                top << line
              else
                # Ignore it, must be a line with a match that was not picked.
              end
            end
          end
        end
        top
      end
  end
end
