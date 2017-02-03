require "net/http"
require "time"
require "./lib/solr_lite/search_params.rb"
require "./lib/solr_lite/search_results.rb"
module SolrLite
  class Solr
    def initialize(solr_url)
      raise "No solr_url was indicated" if solr_url == nil
      @solr_url = solr_url
      @verbose = ENV["SOLR_VERBOSE"] == "true"
      @logger = Rails::logger
    end

    # Fetches a Solr document by id.
    # Returns the document found (or nil if nothing was found)
    # Raises an exception if more than one doc was found.
    def get(id, q_field = "q", fl = "id,json_txt")
      query_string = "#{q_field}=id:#{id_encode(id)}"
      query_string += "&fl=#{fl}"
      query_string += "&wt=json&indent=on"
      url = URI.encode("#{@solr_url}/select?#{query_string}")
      solr_response = http_get(url)
      if solr_response.num_found > 1
        raise "More than one record found for id #{id}"
      end
      solr_response.solr_docs.first
    end

    def search(params)
      if params.fl != nil
        query_string = "fl=#{params.fl.join(",")}"
      else
        query_string = "" # use Solr defaults
      end
      query_string += "&wt=json&indent=on"
      query_string += "&" + params.to_solr_query_string()
      url = URI.encode("#{@solr_url}/select?#{query_string}")
      http_get(url)
    end

    # shortcut for search
    def search_text(terms, facets = ["record_type", "affiliations.name"])
      params = SearchParams.new(terms, facets)
      search(params)
    end

    def start_row(page, page_size)
      (page - 1) * page_size
    end

    def update(json)
      url = @solr_url + "/update?commit=true"
      solr_response = http_post_json(url, json)
      solr_response
    end

    def delete_by_id(id)
      # Use XML format here because that's the only way I could get
      # the delete to recognize ids with a colon (e.g. bdr:123).
      # Using json caused the Solr parser to choke.
      #
      # Notice that they payload is XML but the response is JSON (wt=json)
      url = @solr_url + "/update?commit=true&wt=json"
      payload = "<delete><id>#{id}</id></delete>"
      http_response = http_post(url, payload, "text/xml")
      solr_response = SearchResults.new(JSON.parse(http_response))
      solr_response
    end

    def delete_by_query(query)
      url = @solr_url + "/update?commit=true"
      payload = '{ "delete" : { "query" : "' + query + '" } }'
      solr_response = http_post_json(url, payload)
      solr_response
    end

    def delete_all!()
      delete_by_query("*:*")
    end

    private
      def http_post_json(url, payload)
        content_type = "application/json"
        http_response = http_post(url, payload, content_type)
        SearchResults.new(JSON.parse(http_response))
      end

      def http_post(url, payload, content_type)
        start = Time.now
        log_msg("Solr HTTP POST #{url}")
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if url.start_with?("https://")
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = content_type
        request.body = payload
        response = http.request(request)
        log_elapsed(start, "Solr HTTP POST")
        response.body
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
        SearchResults.new(JSON.parse(response.body))
      end

      def id_encode(id)
        id.gsub(':', '\:')
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
