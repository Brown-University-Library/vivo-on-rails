require "./app/models/model_utils.rb"

class FacultyExportList
    def self.faculty(report_definition)
        faculty_list = []
        faculty_ids = faculty_ids(report_definition)
        faculty_ids.each do |id|
            faculty = Faculty.load_from_solr(id)
            if faculty == nil
                Rails.logger.error("Could not load faculty #{id}.")
            else
                faculty_list << faculty
            end
        end
        faculty_list
    end

    private
        # Fetches the faculty IDs that are needed for this report definition,
        # including specific faculty IDs in the definition and faculty IDs for
        # the people in the given departments.
        def self.faculty_ids(report_definition)
            ids = []
            definition = JSON.parse(report_definition)
            if definition["faculty_ids"]
                definition["faculty_ids"].each do |id|
                    ids << id
                end
            end
            if definition["department_names"]
                definition["department_names"].each do |department|
                    ids += department_faculty(department)
                end
            end
            ids.uniq
        end

        def self.department_faculty(department_name)
            solr_url = ENV["SOLR_URL"]
            logger = ENV["SOLR_VERBOSE"] == "true" ? Rails.logger : nil
            @solr = SolrLite::Solr.new(solr_url, logger)
            fq1 = SolrLite::FilterQuery.new("record_type",["PEOPLE"])
            fq2 = SolrLite::FilterQuery.new("affiliations",[department_name])
            params = SolrLite::SearchParams.new()
            params.fl = ["id"]
            params.page = 1
            params.page_size = 100
            qf = nil
            mm = nil
            debug = true
            faculty_ids = []
            while true
                results = @solr.search(params, [fq1, fq2], qf, mm, debug)
                results.solr_docs.each do |doc|
                    faculty_ids << ModelUtils.vivo_id(doc["id"])
                end
                break if faculty_ids.count == results.num_found
                params.page += 1
            end
            faculty_ids
        end
end
