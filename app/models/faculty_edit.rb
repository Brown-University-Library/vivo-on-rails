class FacultyEdit
    # Reloads faculty information from the edit service. The new
    # information includes extra fields that are needed to edit
    # the faculty records (e.g. ids for research areas and web links)
    def self.reload(faculty)
        @faculty = faculty
        @item = @faculty.item
        @base_url = ENV["EDIT_SERVICE"] + "/" + @item.vivo_id
        verbose = true

        url = @base_url + "/faculty/edit/overview/overview/update"
        data = JsonUtils::http_get(url, verbose)
        if data != nil
            @item.overview = data["overview"] || ""
        end

        url = @base_url + "/faculty/edit/research/areas/update"
        data = JsonUtils::http_get(url, verbose)
        if data != nil
            @item.research_areas = ResearchAreaItem.from_hash_array(data["research_areas"] || [])
        end

        url = @base_url + "/faculty/edit/overview/ontheweb/update"
        data = JsonUtils::http_get(url, verbose)
        if data != nil
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
        # TODO: call Steve's service to do the update
        url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/overview/overview/update"
        payload = {text: text}.to_json
        Rails.logger.info("overview_update: POST #{url} \r\n#{payload}")
        return nil
    end

    def self.research_area_add(faculty_id, text)
        # TODO: call Steve's service to do the update
        url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/research/areas/update"
        payload = {text: text}.to_json
        Rails.logger.info("research_area_update: POST #{url} \r\n#{payload}")
        # return nil, "oops, something went baaaaad"
        return "new-id", nil
    end

    def self.research_area_delete(faculty_id, id)
        # TODO: call Steve's service to do the delete
        url = ENV["EDIT_SERVICE"] + "/" + faculty_id + "/faculty/edit/research/areas/delete"
        payload = {id: ModelUtils::rabid(id)}.to_json
        Rails.logger.info("research_area_delete: POST #{url} \r\n#{payload}")
        return nil
    end
end