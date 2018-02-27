require "./app/models/json_utils.rb"
require "./app/models/search_item.rb"
require "./app/models/faculty.rb"
# require "./lib/solr_lite/filter_query.rb"
# require "./lib/solr_lite/solr.rb"
# require "./lib/solr_lite/search_results.rb"
class Search
  def initialize(solr_url, images_url = nil)
    @images_url = images_url
    @solr = SolrLite::Solr.new(solr_url)
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
    # TODO: test boosting research_areas_txt^400 once we've tokenized them
    qf = "short_id_s^2500 email_s^2500 nameText^2000 " +
    "title_t^1600 department_t^1500 affiliations^450 " +
    "nameUnstemmed^4 nameStemmed^4 nameLowercase ALLTEXT^2 ALLTEXTUNSTEMMED^2"

    if flag != nil
      qf += " research_areas_txt "
    end

    # Require almost all words in the query to match, but not all.
    mm = "99%"

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

      results.items << SearchItem.from_hash(hash, record_type, thumbnail_url)
    end
    results
  end

  def record_type_filter?(params)
    params.fq.find {|f| f.field == "record_type" } != nil
  end
end
