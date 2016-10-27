require "net/http"
require "time"
require "./lib/solr/search_params.rb"
module Solr
  class Solr
    def initialize(solr_url)
      @solr_url = solr_url
      @verbose = ENV["SOLR_VERBOSE"] == "true"
      @logger = Rails::logger
    end

    # Fetches a Solr document by id. Returns the first document found.
    def get(id)
      query_string = "q=id:\"#{id}\""
      query_string += "&fl=id,text"
      query_string += "&wt=json&indent=on"
      url = "#{@solr_url}/select?#{query_string}"
      solr_response = http_get(url)
      solr_response["response"]["docs"].first
    end

    def search(params)
      if params.fl != nil
        query_string = "fl=#{params.fl.join(",")}"
      else
        query_string = ""
      end
      query_string += "&wt=json&indent=on"
      query_string += "&" + params.to_solr_query_string()
      url = "#{@solr_url}/select?#{query_string}"
      http_get(url)
    end

    # shortcut for search
    def search_text(terms)
      facets = ["record_type", "affiliations.name"]
      params = SearchParams.new(terms, facets)
      search(params)
    end

    def start_row(page, page_size)
      (page - 1) * page_size
    end

    def update(json)
      url = @solr_url + "/update/json/docs"
      r1 = http_post(url, json)
      r2 = commit()
      [r1, r2]
    end

    # Saves the document but does not commit it
    # (it's up to the caller to call commit)
    def update_fast(json)
      url = @solr_url + "/update/json/docs"
      r1 = http_post(url, json)
      [r1, nil]
    end

    def delete_all!()
      url = @solr_url + "/update"
      payload = "<delete><query>*:*</query></delete>"
      payload = '{ "delete" : { "query" : "*:*" } }'
      r1 = http_post(url, payload)
      r2 = commit()
      [r1, r2]
    end

    def commit()
      commit_url = @solr_url + "/update?commit=true"
      http_get(commit_url)
    end

    private
      def http_post(url, payload)
        start = Time.now
        log_msg("Solr HTTP POST #{url}")
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if url.start_with?("https://")
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        request.body = payload
        response = http.request(request)
        log_elapsed(start, "Solr HTTP POST")
        JSON.parse(response.body)
      end

      def http_get(url)
        start = Time.now
        log_msg("Solr HTTP GET #{url}")
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if url.start_with?("https://")
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Get.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        response = http.request(request)
        log_elapsed(start, "Solr HTTP GET")
        JSON.parse(response.body)
      end

      def elapsed_ms(start)
        ((Time.now - start) * 1000).to_i
      end

      def log_elapsed(start, msg)
        log_msg("#{msg} took #{elapsed_ms(start)} ms")
      end

      def log_msg(msg)
        return if @verbose == false
        if @logger
          @logger.info msg
        else
          puts msg
        end
      end
  end
end
