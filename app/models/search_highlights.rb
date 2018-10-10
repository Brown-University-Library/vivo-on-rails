require "./app/models/search_hit.rb"

class SearchHighlights
  def initialize(solr_doc_highlights)
    @highlights = parse_highlights(solr_doc_highlights)
  end

  def count()
    @highlights.count
  end

  # Returns the HTML representation for the "top N" highlights.
  #
  # The "top N" are picked up from the original solr_doc_highlights
  # but we try to include as many different search terms as possible
  # rather than the same term multiple times. For example, if the
  # user searched for three terms we try to include highlights for
  # all three terms rather than five highlights for the first one.
  #
  # TODO: This code is hard-coded to match our fields.
  # Consider making it configurable after we go live.
  def html(count)
    html = ""
    hits = top_hits(count)

    # Gather the highlights in order: department + research areas + overview.
    html += html_for_field(hits, "department_t", "Department")
    html += html_for_field(hits, "research_areas_en", "Research areas")
    html += html_for_field(hits, "affiliations_en", "Affiliations")
    html += html_for_field(hits, "overview_en", "Overview")

    # and then highlights for the rest of the fields (i.e. ALLTEXT)
    hits.each do |hit|
      if hit.field == "research_areas_en" || hit.field == "affiliations_en" ||
        hit.field == "department_t" || hit.field == "overview_en"
        next
      end
      html += "<p>#{hit.value}</p>"
    end

    clean_html(html)
  end

  private
    # Returns all values for all the highlights, including duplicate hits.
    # For example if the word "research" was found 3 times, 3 results for it will
    # be returned.
    def all_hits()
      hits = []
      @highlights.each do |hl|
        hl[:values].each do |value|
          hits << SearchHit.new(hl[:field], value)
        end
      end
      hits
    end

    # HTML encode problematic characters so that we can render them safely
    # as HTML. Notice that we purposefuly preserve a few HTML tags like
    # <p> and <strong>.
    def clean_html(html)
      # Mark the HTML tags that we want to preserve.
      html.gsub!('<p>', '{p}')
      html.gsub!('</p>', '{/p}')
      html.gsub!('<strong>', '{strong}')
      html.gsub!('</strong>', '{/strong}')

      # Replace dangerous characters.
      html.gsub!("'", '&#39;')
      html.gsub!('"', '&quot;')
      html.gsub!('<', '&lsaquo;')   # looks like < but it's ‹
      html.gsub!('>', '&rsaquo;')   # looks like > but it's ›

      # Restore the HTML tags that we want to preserve
      html.gsub!('{p}', '<p>')
      html.gsub!('{/p}', '</p>')
      html.gsub!('{strong}', '<strong>')
      html.gsub!('{/strong}', '</strong>')

      # Remove the VIVO identifier from the text since it's meaningless to
      # the user.
      html.gsub!("Agent Faculty Member Organization or Person at Brown Person", "")
      html
    end

    def strip_html(html)
      stripped = html
      stripped = stripped.gsub('<p>', '')
      stripped = stripped.gsub('</p>', '')

      # https://stackoverflow.com/questions/2588942/convert-non-breaking-spaces-to-spaces-in-ruby
      stripped = stripped.gsub(/\u00a0/, ' ')

      stripped = stripped.gsub(/\s\s+/, ' ')  # consolidate spaces
      stripped
    end

    def html_for_field(hits, field_name, caption)
      html = ""
      field_hits = hits.map {|hit| hit.field == field_name ? hit.value : nil}.compact
      if field_hits.count > 0
        html += "<p>#{caption}: " + strip_html(field_hits.join(", ")) + "</p>"
      end
      html
    end

    def parse_highlights(solr_highlights)
      return [] if solr_highlights == nil
      parsed = []
      solr_highlights.keys.each do |key|
        item = {
          field: key,
          values: solr_highlights[key].map {|value| value.strip}
        }
        parsed << item
      end
      parsed
    rescue
      return []
    end

    def top_hits(count)
      hits = unique_hits()
      if hits.count >= count
        # We got plenty of unique terms. We are done.
        return hits
      end

      all = all_hits()
      if hits.count == all.count
        # We've got as much as we are going to get. We are done.
        return hits
      end

      # We have less unique hits than the max requested see if
      # can add a few extra non-unique hits.
      all.each do |value|
        duplicate = hits.find {|x| x.value == value.value} != nil
        if !duplicate
          hits << value
          break if hits.count >= count
        end
      end
      hits
    end

    # Returns an array of SearchHits, one item per search term. For example
    # if the word "research" was found 3 times for a Solr document only the
    # first instance for it will be returned.
    def unique_hits()
      hits = []
      unique_terms.each do |term|
        # For each unique term find the first instance of it in
        # the highlights and collect it
        @highlights.each do |hl|
          snippet = hl[:values].find {|value| value.upcase.include?(term) }
          if snippet != nil
            if hits.find {|x| x.value == snippet} == nil
              hits << SearchHit.new(hl[:field], snippet)
              break
            else
              # We already have this snippet, don't re-add it.
              # This prevents adding the same snippet twice because it
              # matched two different terms.
            end
          end
        end
      end
      hits
    end

    # Returns the unique terms. Notice that it's case insensitive.
    #
    # For example if the highlights include:
    #     [
    #       "abc<strong>Value 1</strong>xyz",
    #       "abc<strong>Value 2</strong>xyz",
    #       "abc<strong>VALUE 1</strong>xyz"
    #     ]
    #
    # the returning value will be
    #     [
    #       "<strong>VALUE 1</strong>
    #       "<strong>VALUE 2</strong>"
    #     ]
    #
    def unique_terms()
      terms = []
      @highlights.each do |hl|
        hl[:values].each do |snippet|
          # Notice that we use the lazy match (.*?) because the snippet
          # could contain multiple matches (e.g. on a multi-word search)
          hits = snippet.scan(/<strong>.*?<\/strong>/)
          hits.each do |hit|
            terms << hit.upcase
          end
        end
      end
      terms.uniq()
    end
end
