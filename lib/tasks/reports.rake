require "./app/models/book_cover.rb"
namespace :vivo do
  desc "Initializes the reports tablewith default data"
  task :reports_init => :environment do
    def1 = {faculty_ids: faculty_list()}.to_json
    r1 = Report.new(name: "Emily Ferrier Report 1", description: "List of individual faculty", definition: def1)
    r1.save!

    def2 = {department_names: department_list()}.to_json
    r2 = Report.new(name: "Emily Ferrier Report 2", description: "List of multiple departments", definition: def2)
    r2.save!
  end
end

def faculty_list()
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

def department_list()
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
    departments
end