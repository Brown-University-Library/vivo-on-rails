require "./app/models/model_utils.rb"
require "./app/models/faculty_export.rb"

class ReportsController < ApplicationController
  def subject_lib_list
  end

  def subject_lib
    faculty_ids = []
    format = params["format"]
    list_id = params["list_id"]
    faculty_ids = FacultyExportList.faculty_list(list_id)
    if faculty_ids.count == 0
      @page_title = "Page not found"
      err_msg = "List ID (#{list_id}) was not found"
      Rails.logger.warn(err_msg)
      render "not_found", status: 404, formats: [:html]
      return
    end

    Rails.logger.info("Exporting...")
    faculty_list = []
    faculty_ids.each do |id|
        faculty = Faculty.load_from_solr(id)
        if faculty == nil
            Rails.logger.error("Could not render faculty #{id}.")
        else
            faculty_list << faculty
        end
    end
    export = FacultyExport.new(faculty_list)
    if format == "xml"
      Rails.logger.info("Generating XML...")
      send_data export.to_excel(), :type => "application/xml", :filename=>"#{list_id}.xml", :disposition => 'attachment'
    else
      Rails.logger.info("Generating CSV...")
      send_data export.to_csv(), :type => "text/plain", :filename=>"#{list_id}.csv", :disposition => 'attachment'
    end
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not produce export file for #{list_id}, format #{params['format']}. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end
end
