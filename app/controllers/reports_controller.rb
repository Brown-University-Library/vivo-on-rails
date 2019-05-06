require "./app/models/model_utils.rb"
require "./app/models/faculty_export.rb"

class ReportsController < ApplicationController
  def subject_lib
    faculty_ids = []
    if params["librarian"] == "eferrier"
        faculty_ids = eferrier_list()
    end
    Rails.logger.info("Exporting...")
    faculty_list = []
    faculty_ids.each do |id|
        Rails.logger.info("Loading #{id}...")
        faculty = Faculty.load_from_solr(id)
        if faculty == nil
            Rails.logger.error("Could not render faculty #{id}.")
        else
            faculty_list << faculty
        end
    end
    Rails.logger.info("Generating CSV...")
    export = FacultyExport.new(faculty_list)
    render :text => export.to_csv()
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not render record #{id}, type #{type}. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end

  def eferrier_list()
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
