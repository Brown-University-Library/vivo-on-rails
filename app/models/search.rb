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
      Rails.logger.warn "RECORD_TYPE: added PEOPLE OR ORGANIZATION"
      fq = SolrLite::FilterQuery.new("record_type",["PEOPLE", "ORGANIZATION"])
      extra_fqs = [fq]
    else
      Rails.logger.warn "RECORD_TYPE: already filtered"
    end
    params.fl = ["id", "record_type", "json_txt"]
    results = @solr.search(params, extra_fqs)
    results.solr_docs.each do |doc|
      record_type = (doc["record_type"] || []).first
      json_txt = doc["json_txt"].first
      if record_type != "ORGANIZATION" && record_type != "PEOPLE"
        # A VIVO type not supported on our new front-end.
        # TODO: we should either filter them our in our `q` parameter
        # so that they are not returned at all.
        Rails.logger.warn("Ignored record_type: #{record_type}. #{json_txt}")
        next
      end

      hash = JsonUtils.safe_parse(json_txt)
      if hash == nil
        next
      end

      results.items << SearchItem.from_hash(hash, record_type)
    end
    results
  end

  def record_type_filter?(params)
    params.fq.find {|f| f.field == "record_type" } != nil
  end
end
