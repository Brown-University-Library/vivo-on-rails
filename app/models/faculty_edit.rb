class FacultyEdit
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
            # For now use a new property for the edit array in order to be able to
            # handle label + id, the existing array only handles label.
            @item.research_areas_edit = ResearchAreaItem.from_hash_array(data["research_areas"] || [])
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
        payload = {id: rabid(id)}.to_json
        Rails.logger.info("research_area_delete: POST #{url} \r\n#{payload}")
        return nil
    end

    def self.rabid(id)
        "http://vivo.brown.edu/individual/#{id}"
    end
end