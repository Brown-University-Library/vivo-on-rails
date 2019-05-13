require "./app/models/model_utils.rb"

class FacultyExportList

    def self.faculty_list(list_id)
        case list_id
        when "eferrier"
            return self.eferrier_list()
        when "eferrier_large"
            return self.eferrier_larger_list()
        else
            []
        end
    end

    private
    def self.eferrier_larger_list()
        departments = []
        departments << "Anthropology"
        departments << "Behavioral and Social Sciences"
        departments << "Economics"
        departments << "Education"
        departments << "Modern Culture and Media"
        departments << "Political Science"
        departments << "Sociology"
        departments << "Annenberg Institute"
        departments << "Business, Entrepreneurship and Organizations"
        departments << "International and Public Affairs"
        departments << "Pembroke Center"
        departments << "Political Theory"
        departments << "Population Studies & Training Center"
        departments << "Race and Ethnicity in America"
        departments << "Science and Technology Studies"
        departments << "Spatial Structures in the Social Sciences"
        departments << "Urban Studies"

        faculty_ids = []
        departments.each do |department|
            faculty_ids += department_faculty(department)
        end
        faculty_ids.uniq
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

    def self.eferrier_list()
        faculty_ids = []
        faculty_ids << "afoster"
        faculty_ids << "anorets"
        faculty_ids << "aikingon"
        faculty_ids << "adill"
        faculty_ids << "anaizer"
        faculty_ids << "bhazelti"
        faculty_ids << "bpakzadh"
        faculty_ids << "bmcnally"
        faculty_ids << "bknight"
        faculty_ids << "mmillett"
        faculty_ids << "cspearin"
        faculty_ids << "dhirsch1"
        faculty_ids << "dbjorkeg"
        faculty_ids << "dwarshay"
        faculty_ids << "dlindstr"
        faculty_ids << "dweil"
        faculty_ids << "eoster1"
        faculty_ids << "erenault"
        faculty_ids << "esuuberg"
        faculty_ids << "geggerts"
        faculty_ids << "gdeclipp"
        faculty_ids << "gloury"
        faculty_ids << "jfanning"
        faculty_ids << "jharry"
        faculty_ids << "jnazaren"
        faculty_ids << "jshapir1"
        faculty_ids << "jblaum"
        faculty_ids << "jfriedm2"
        faculty_ids << "jh87"
        faculty_ids << "krozen"
        faculty_ids << "kchay"
        faculty_ids << "lbarrage"
        faculty_ids << "ldicarlo"
        faculty_ids << "lputterm"
        faculty_ids << "msuchman"
        faculty_ids << "mturner1"
        faculty_ids << "nrmehrot"
        faculty_ids << "nthakral"
        faculty_ids << "ogalor"
        faculty_ids << "pmichail"
        faculty_ids << "paheller"
        faculty_ids << "pm5"
        faculty_ids << "pdalbo"
        faculty_ids << "rfriedbe"
        faculty_ids << "rlaporta"
        faculty_ids << "rvohra"
        faculty_ids << "rserrano"
        faculty_ids << "smichalo"
        faculty_ids << "sschenna"
        faculty_ids << "skuo"
        faculty_ids
      end
end
