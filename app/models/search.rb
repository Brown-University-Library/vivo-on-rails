require "./app/models/json_utils.rb"
require "./app/models/search_item.rb"
require "./app/models/faculty.rb"
class Search
  def initialize(solr_url, images_url = nil)
    @images_url = images_url
    logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil
    @solr = SolrLite::Solr.new(solr_url, logger)
  end

  def search(params, debug = false, flag = nil)
    extra_fqs = []
    if !record_type_filter?(params)
      # VIVO stores many kind of documents in Solr. We only care about
      # the ones explicitly marked as PEOPLE or ORGANIZATION. We store
      # all the information that we need in these two kind of records.
      fq = SolrLite::FilterQuery.new("record_type",["PEOPLE", "ORGANIZATION"])
      extra_fqs = [fq]
    end
    params.fl = ["id", "record_type", "thumbnail_file_path_s", "json_txt"]

    # Query filter with custom boost values
    #
    # TODO: Use this new qf once we update the production Solr with the new
    #       fields (research_areas_en and affiliations_en)
    #       Make sure we also include them under params.hl_fl below.
    #
    # qf = "short_id_s^2500 email_s^2500 nameText^2000 " +
    # "title_t^1600 department_t^1500 research_areas_en^400 affiliations_en^450 " +
    # "nameUnstemmed^4 nameStemmed^4 nameLowercase ALLTEXT^2 ALLTEXTUNSTEMMED^2"
    #
    qf = "short_id_s^2500 email_s^2500 nameText^2000 " +
    "title_t^1600 department_t^1500 research_areas_txt^400 affiliations^450 " +
    "nameUnstemmed^4 nameStemmed^4 nameLowercase ALLTEXT^2 ALLTEXTUNSTEMMED^2"

    # Hit highlighting
    if ENV["SOLR_HIGHLIGHT"] == "true"
      params.hl = true
      # Notice that we don't highlight name_t and title_t because we always
      # display those values.
      params.hl_fl = "department_t research_areas_txt affiliations overview_t ALLTEXT email_s short_id_s"
      # A large number here allows us to get a large number of hits which is
      # useful for searches with 3 or more search terms. However, this value
      # increases the size of the response and we might need to reduce it if
      # results in performance issues.
      params.hl_snippets = 30
    end

    # For information on Solr's Minimum match value see
    #   "Solr in Action" p. 229
    #   and https://lucene.apache.org/solr/guide/6_6/the-dismax-query-parser.html
    #
    # Search terms    Criteria
    # ------------    ------------
    # 1,2             all search terms must be found
    # 3+              at least 75% of the terms must be found
    #                 (this helps with stop words, eg. "professor of history")
    mm = "2<75%"

    results = @solr.search(params, extra_fqs, qf, mm, debug)
    if !results.ok?
      raise("Solr reported: #{results.error_msg}")
    end

    results.solr_docs.each do |doc|
      record_type = (doc["record_type"] || []).first
      thumbnail = doc["thumbnail_file_path_s"]
      json_txt = doc["json_txt"].first
      if record_type != "PEOPLE" && record_type != "ORGANIZATION"
        # A VIVO type not supported on our new front-end.
        Rails.logger.warn("Ignored record_type: #{record_type}. #{json_txt}")
        next
      end

      hash = JsonUtils.safe_parse(json_txt)
      if hash == nil
        next
      end

      thumbnail_url = ModelUtils.thumbnail_url(thumbnail, @images_url)
      if thumbnail != nil && thumbnail_url == nil
        Rails.logger.warn "Could not calculate thumbnail URL for #{thumbnail} (#{hash['id']})"
      end

      if ENV["SOLR_HIGHLIGHT"] == "true"
        doc_id = "vitroIndividual:#{doc['id']}"
        highlights = results.highlights.for(doc_id)
      else
        highlights = []
      end

      results.items << SearchItem.from_hash(hash, record_type, thumbnail_url, highlights)
    end
    results
  end

  def record_type_filter?(params)
    params.fq.find {|f| f.field == "record_type" } != nil
  end
end
