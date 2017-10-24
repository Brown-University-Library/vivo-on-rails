require "./app/models/json_utils.rb"
require "./app/models/search_item.rb"
require "./app/models/faculty.rb"
require "./lib/solr_lite/filter_query.rb"
require "./lib/solr_lite/solr.rb"
require "./lib/solr_lite/search_results.rb"
class Search
  def initialize(solr_url)
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
    results = @solr.search(params, extra_fqs)
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

      results.items << SearchItem.from_hash(hash, record_type, thumbnail)
    end
    results
  end

  def record_type_filter?(params)
    params.fq.find {|f| f.field == "record_type" } != nil
  end
end
