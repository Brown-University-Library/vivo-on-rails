class FacultyEdit
    def initialize(faculty, verbose = false)
        @faculty = faculty
        @item = @faculty.item
        @base_url = ENV["EDIT_SERVICE"] + "/" + @item.vivo_id + "/faculty/edit"
        @verbose = verbose
        if ENV["EDIT_SERVICE"].start_with?("mock://")
            JsonUtils::mock_request_on()
        end
    end

    # Reloads faculty information from the edit service. The new
    # information includes extra fields that are needed to edit
    # the faculty records (e.g. ids for research areas and web links)
    def reload()
        @item.overview = simple_text_get(@item.overview, "/overview/overview", "overview") || ""
        return if @faculty.has_errors?

        url = @base_url + "/overview/research-areas"
        data = JsonUtils::http_get(url, @verbose)
        if data == nil
            @faculty.add_error("Could not fetch research areas data for edit")
            return
        elsif data["error"]
            @faculty.add_error("Could not fetch research areas data for edit. Error: #{data['error']}.")
            return
        end
        @item.research_areas = ResearchAreaItem.from_hash_array(data["research_areas"] || [])

        url = @base_url + "/overview/ontheweb"
        data = JsonUtils::http_get(url, @verbose)
        if data == nil
            @faculty.add_error("Could not fetch on the web data for edit")
            return
        elsif data["error"]
            @faculty.add_error("Could not fetch on the web data for edit. Error: #{data['error']}.")
            return
        end

        # convert the links to the expected format
        links = data["web_links"] || []
        links = links.map do |link|
            { uri: link["rabid"], rank: link["rank"], text: link["text"], url: link["url"] }
        end
        @item.on_the_web = OnTheWebItem.from_hash_array(links)

        @item.research_overview = simple_text_get(@item.research_overview, "/research/overview", "research_overview")
        return if @faculty.has_errors?

        @item.research_statement = simple_text_get(@item.research_statement, "/research/statement", "research_statement")
        return if @faculty.has_errors?

        @item.funded_research = simple_text_get(@item.funded_research, "/research/funded", "funded_research")
        return if @faculty.has_errors?

        @item.scholarly_work = simple_text_get(@item.scholarly_work, "/research/scholarly", "scholarly_work")
        return if @faculty.has_errors?

        @item.awards = simple_text_get(@item.awards,"/background/honors","awards_honors")
        return if @faculty.has_errors?

        @item.affiliations_text = simple_text_get(@item.affiliations_text, "/affiliations/affiliations", "affiliations")
        return if @faculty.has_errors?

        @item.teaching_overview = simple_text_get(@item.teaching_overview, "/teaching/overview", "teaching_overview")
    end

    def simple_text_get(value, url_suffix, key)
        if value == nil || value == ""
            # Just the value as-is, no need to fetch it.
            return value
        end

        # Fetch value from the Edit service.
        # We probably could eliminate this call since the value is just text
        # (i.e. no extra fields are needed).
        url = @base_url + url_suffix
        data = JsonUtils::http_get(url, @verbose)
        if data == nil
            Rails.logger.error("Error fetching #{key}. URL: #{url}.")
            @faculty.add_error("Could not fetch #{key} data for edit")
            return value
        elsif data["error"] != nil
            Rails.logger.error("Error fetching #{key}. URL: #{url}. Error: #{data['error']}")
            @faculty.add_error("Could not fetch #{key} data for edit")
            return value
        elsif data[key] == nil
            Rails.logger.error("Error fetching #{key}. URL: #{url}. No data.")
            @faculty.add_error("Could not fetch #{key} data for edit")
            return value
        end

        return data[key]
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
        if data == nil
            Rails.logger.error("Error updating #{key}.")
            return nil, "Error updating #{key}."
        elsif data["error"]
            Rails.logger.error("Error updating #{key}. Error: #{data['error']}")
            return nil, "Error updating #{key}."
        end
        return data[key], nil
    end
end