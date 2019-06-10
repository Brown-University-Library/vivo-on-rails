require "./app/models/model_utils.rb"
require "./app/models/faculty_export.rb"

class ReportsController < ApplicationController
  def subject_lib_list
    must_be_authenticated()
    reports = Report.all()
    @presenter = ReportsPresenter.new(current_user, reports)
  end

  def subject_lib
    must_be_authenticated()
    format = params["format"]
    list_id = params["list_id"]
    id = (list_id || "").to_i

    # Fetch the report definition
    report = Report.find_by_id(id)
    if report == nil
      @page_title = "Page not found"
      err_msg = "Report ID (#{list_id}) was not found"
      Rails.logger.warn(err_msg)
      render "not_found", status: 404, formats: [:html]
      return
    end

    # Fetch the data
    Rails.logger.info("Fetching faculty for #{list_id}...")
    faculty_list = FacultyExportList.faculty(report.definition)

    # Produce the export
    export = FacultyExport.new(faculty_list)
    if format == "xml"
      Rails.logger.info("Generating XML...")
      send_data export.to_excel(),
        :type => "application/xml",
        :filename => report.download_name("xml"),
        :disposition => 'attachment'
    else
      Rails.logger.info("Generating CSV...")
      send_data export.to_csv(),
        :type => "text/plain",
        :filename=> report.download_name("csv"),
        :disposition => 'attachment'
    end
  rescue => ex
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Could not produce export file for #{list_id}, format #{params['format']}. Exception: #{ex} \r\n #{backtrace}")
    render "error", status: 500
  end
end
