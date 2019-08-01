class FacultyEdit
    # Reloads faculty information from the edit service. The new
    # information includes extra fields that are needed to edit
    # the faculty records (e.g. ids for research areas and web links)
    def self.reload(faculty)
        @faculty = faculty
        @item = @faculty.item
        @base_url = ENV["EDIT_SERVICE"] + "/" + @item.vivo_id
        verbose = true

        url = @base_url + "/faculty/edit/overview/overview"
        data = JsonUtils::http_get(url, verbose)
        if data == nil
            @faculty.add_error("Could not fetch overview data for edit")
        else
            @item.overview = data["overview"] || ""
        end

        url = @base_url + "/faculty/edit/overview/research-areas"
        data = JsonUtils::http_get(url, verbose)
        if data == nil
            @faculty.add_error("Could not fetch research areas data for edit")
        else
            @item.research_areas = ResearchAreaItem.from_hash_array(data["research_areas"] || [])
        end

        url = @base_url + "/faculty/edit/overview/ontheweb"
        data = JsonUtils::http_get(url, verbose)
        if data == nil
            @faculty.add_error("Could not fetch on the web data for edit")
        else
            # convert the links to the expected format
            links = data["web_links"] || []
            links = links.map do |link|
                {
                    uri: link["rabid"],
                    rank: link["rank"],
                    text: link["text"],
                    url: link["url"]
                }
            end
            @item.on_the_web = OnTheWebItem.from_hash_array(links)
        end

        if @item.research_overview != nil && @item.research_overview != ""
            url = @base_url + "/faculty/edit/research/overview"
            data = JsonUtils::http_get(url, verbose)
            if data == nil
                @faculty.add_error("Could not fetch reseach overview data for edit")
            else
                @item.research_overview = data["research_overview"]
            end
        end

        if @item.research_statement != nil && @item.research_statement != ""
            url = @base_url + "/faculty/edit/research/statement"
            data = JsonUtils::http_get(url, verbose)
            if data == nil
                @faculty.add_error("Could not fetch reseach statement data for edit")
            else
                @item.research_statement = data["research_statement"]
            end
        end

        if @item.funded_research != nil && @item.funded_research != ""
            url = @base_url + "/faculty/edit/research/funded"
            data = JsonUtils::http_get(url, verbose)
            if data == nil
                @faculty.add_error("Could not fetch funded research data for edit")
            else
                @item.funded_research = data["funded_research"]
            end
        end

        if @item.scholarly_work != nil && @item.scholarly_work != ""
            url = @base_url + "/faculty/edit/research/scholarly"
            data = JsonUtils::http_get(url, verbose)
            if data == nil
                @faculty.add_error("Could not fetch scholarly work data for edit")
            else
                @item.scholarly_work = data["scholarly_work"]
            end
        end

        if @item.awards != nil && @item.awards != ""
            url = @base_url + "/faculty/edit/background/honors"
            data = JsonUtils::http_get(url, verbose)
            if data == nil
                @faculty.add_error("Could not awards honors work data for edit")
            else
                @item.awards = data["awards_honors"]
            end
        end
    end

    def self.research_area_add(faculty_id, text)
        url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/overview/research-areas/add"
        payload = {name: text}.to_json
        Rails.logger.info("research_area_update: POST #{url} \r\n#{payload}")
        data = JsonUtils::http_post(url, payload)
        if data == nil || data["error"] != nil
            return nil, "Error adding research areas"
        end
        return data["rabid"], nil
    end

    def self.research_area_delete(faculty_id, id)
        url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/overview/research-areas/delete"
        payload = {rabid: ModelUtils::rabid(id)}.to_json
        Rails.logger.info("research_area_delete: POST #{url} \r\n#{payload}")

        data = JsonUtils::http_post(url, payload)
        if data == nil || data["error"] != nil
            return nil, "Error adding research areas"
        end
        return data["deleted"], nil
    end

    def self.web_link_save(faculty_id, text, link_url, rank, id)
        if id == "new-id"
            url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/overview/ontheweb/add"
            payload = {
                text: text,
                url: link_url,
                rank: rank
            }.to_json
            Rails.logger.info("web_link_save (new): POST #{url} \r\n#{payload}")
            data = JsonUtils::http_post(url, payload)
            if data == nil || data["error"] != nil
                return nil, "Error adding web link"
            end
            return data["rabid"], nil
        else
            url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/overview/ontheweb/update"
            payload = {
                rabid: ModelUtils::rabid(id),
                text: text,
                url: link_url,
                rank: rank
            }.to_json
            Rails.logger.info("web_link_save (update): POST #{url} \r\n#{payload}")
            data = JsonUtils::http_post(url, payload)
            if data == nil || data["error"] != nil
                return nil, "Error updating web link"
            end
            return data["rabid"], nil
        end
    end

    def self.web_link_delete(faculty_id, id)
        url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/overview/ontheweb/delete"
        payload = {rabid: ModelUtils::rabid(id)}.to_json
        Rails.logger.info("web_link_delete: POST #{url} \r\n#{payload}")
        data = JsonUtils::http_post(url, payload)
        if data == nil || data["error"] != nil
            return nil, "Error deleting web link"
        end
        return data["deleted"], nil
    end

    # Updates simple text data elements via the API.
    # The data we pass to the API is in format:
    #           {key: text}
    # and the result is on the exact same format.
    def self.simple_text_update(url_suffix, faculty_id, text, key)
        url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/" + url_suffix
        data = {}
        data[key] = ModelUtils::html_trim(text)
        payload = data.to_json
        Rails.logger.info("POST #{url} \r\n#{payload}")
        data = JsonUtils::http_post(url, payload)
        if data == nil || data["error"] != nil
            Rails.logger.error("Error updating research overview (#{data['error']})")
            return nil, "Error updating overview"
        end
        return data[key], nil
    end
end