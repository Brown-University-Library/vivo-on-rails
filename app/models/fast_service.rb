class FastService
    def self.search(text, oclc = false)
        if oclc
            return search_oclc(text)
        end
        return search_bdr(text)
    end

    def self.search_bdr(text)
        url = "https://repository.library.brown.edu/services/fast-select2/?query=#{text}"
        verbose = true
        data = JsonUtils::http_get(url, verbose)
        if data == nil
            Rails.logger.error("BDR FAST service unresponsive")
            return []
        end

        if data["err"] != nil
            error = data["err"]
            Rails.logger.error("BDR FAST service error: #{error}")
            return []
        end

        results = []
        data["results"].each do |item|
            tokens = item["id"].split("\t")
            id = tokens[0]
            name = tokens[1]
            result = {id: id, label: name, value: name}
            results << result
        end
        return results
    end

    def self.search_oclc(text)
        url = "http://fast.oclc.org/searchfast/fastsuggest?query=#{text}&queryReturn=idroot,auth,type,suggestall&suggest=autoSubject"
        verbose = true
        data = JsonUtils::http_get(url, verbose)
        if data == nil
            Rails.logger.error("FAST service unresponsive")
            return []
        end

        if data["response"] == nil || data["response"]["docs"] == nil
            Rails.logger.error("Unexpected result received from the FAST service")
            return []
        end

        results = []
        data["response"]["docs"].each do |doc|
            id = doc["idroot"]
            rec_type doc["type"]
            name = doc["auth"]
            # For alternate terms show the alternate label instead.
            if rec_type != 'auth'
                if (doc["suggestall"] || []).count == 0
                    next
                end
                name = doc["suggestall"][0]
            end
            result = {id: id, label: name, value: name}
            # result = {uri: item_uri(id), id: id, text: name  }
            results << result
        end
        return results
    end

    def self.item_uri(id)
        base_url = "http://id.worldcat.org/fast/"
        clean_id = id.gsub(/\Afst/,'').gsub(/\A0*/,"")
        base_url + clean_id
    end
end