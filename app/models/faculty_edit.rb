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
    end

    def self.overview_update(faculty_id, text)
        url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/overview/overview/update"
        payload = {overview: text}.to_json
        Rails.logger.info("overview_update: POST #{url} \r\n#{payload}")
        data = JsonUtils::http_post(url, payload)
        if data == nil
            return "Error updating overview"
        end
        return nil
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
            Rails.logger.info("web_link_add: POST #{url} \r\n#{payload}")
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
            Rails.logger.info("web_link_update: POST #{url} \r\n#{payload}")
            data = JsonUtils::http_post(url, payload)
            if data == nil || data["error"] != nil
                return nil, "Error adding web link"
            end
            return data["rabid"], nil
        end
    end
end