require "./app/models/json_utils.rb"
require "./app/models/search_item.rb"
require "./app/models/faculty.rb"
require "./lib/solr_lite/filter_query.rb"
require "./lib/solr_lite/solr.rb"
require "./lib/solr_lite/search_results.rb"
class Search
  def initialize(solr_url, images_url = nil)
    @images_url = images_url
    @solr = SolrLite::Solr.new(solr_url)
  end

  def search(params)
    extra_fqs = []
    if !record_type_filter?(params)
      # VIVO stores many kind of documents in Solr. We only care about
      # the ones explicitly marked as PEOPLE or ORGANIZATION. We store
      # all the information that we need in these two kind of records.
      fq = SolrLite::FilterQuery.new("record_type",["PEOPLE", "ORGANIZATION"])
      extra_fqs = [fq]
    end
    params.fl = ["id", "record_type", "thumbnail_file_path_s", "json_txt"]

    # Remove this once Steve updates the server's values.
    qf = "short_id_s^2500 email_s^2500 nameText^2000 title_t^1600 department_t^1500 " +
      "affiliations^450 research_areas^400 " +
      "ALLTEXT ALLTEXTUNSTEMMED nameUnstemmed^2.0 nameStemmed^2.0 nameLowercase"

    results = @solr.search(params, extra_fqs, qf)
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
