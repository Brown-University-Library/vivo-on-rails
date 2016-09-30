require "net/http"
module Solr
  class Solr
    def initialize(solr_url)
      @solr_url = solr_url
    end

    def search(search_term)
      query_string = "?fl=uri&indent=on&q=#{search_term}&wt=json"
      url = "#{@solr_url}/select?#{query_string}"
      get(url)
    end

    def update(json)
      url = @solr_url + "/update/json/docs"
      r1 = post(url, json)
      r2 = commit()
      [r1, r2]
    end

    def delete_all!()
      url = @solr_url + "/update"
      payload = "<delete><query>*:*</query></delete>"
      payload = '{ "delete" : { "query" : "*:*" } }'
      r1 = post(url, payload)
      r2 = commit()
      [r1, r2]
    end

    private
      def post(url, payload)
        puts "Solr HTTP POST #{url}"
        # puts payload
        # puts "--"
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
        JSON.parse(response.body)
      end

      def get(url)
        puts "Solr HTTP GET #{url}"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if url.start_with?("https://")
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Get.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        response = http.request(request)
        JSON.parse(response.body)
      end

      def commit()
        commit_url = @solr_url + "/update?commit=true"
        get(commit_url)
      end
  end
end
