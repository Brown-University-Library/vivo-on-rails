require "csv"
require "./app/models/model_utils.rb"
class FacultyExport
  def initialize(faculty_list)
    @faculty_list = faculty_list
  end

  def to_csv()
    all = general_info_csv() + "\r\n" +
      teacher_for_csv() + "\r\n" +
      contributor_to_csv() + "\r\n" +
      published_in_csv() + "\r\n" +
      text_fields_csv()
    all
  end

  def contributor_to_csv()
    array_to_csv(contributor_to())
  end

  def general_info_csv()
    array_to_csv(general_info())
  end

  def published_in_csv()
    array_to_csv(published_in())
  end

  def teacher_for_csv()
    array_to_csv(teacher_for())
  end

  def text_fields_csv()
    array_to_csv(text_fields())
  end

  def array_to_csv(the_array)
    options = {headers: true}
    str = CSV.generate(options) do |csv|
      the_array.each { |row| csv << row }
    end
    str
  end

  def contributor_to()
    rows = []
    rows << ["Name", "Organization", "Title", "Type", "Volume", "Issue", "Date", "Authors", "Venue", "DOI", "Year", "Published In"]
    @faculty_list.each do |faculty|
      baseRow = [faculty.item.name, faculty.item.org_label, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
      if faculty.item.research_areas.count == 0
          rows << baseRow
      else
          faculty.item.contributor_to.each do |pub|
              row = baseRow.clone
              row[2] = pub.title
              row[3] = pub.pub_type
              row[4] = pub.volume
              row[5] = pub.issue
              row[6] = pub.date
              row[7] = pub.authors
              row[8] = pub.venue
              row[9] = pub.doi
              row[10] = pub.year
              row[11] = pub.published_in
              rows << row
          end
      end
    end
    rows
  end

  def general_info()
    rows = []
    rows << ["Name", "Organization", "Title", "FIS updated", "Profile updated", "CV link", "Research Area"]
    @faculty_list.each do |faculty|
      baseRow = [faculty.item.name,
      faculty.item.org_label, faculty.item.title,
      faculty.item.fis_updated, faculty.item.profile_updated,
      faculty.item.cv_link, nil]
      if faculty.item.research_areas.count == 0
          rows << baseRow
      else
          faculty.item.research_areas.each do |research_area|
              row = baseRow.clone
              row[6] = research_area
              rows << row
          end
      end
    end
    rows
  end

  def published_in()
    rows = []
    rows << ["Name", "Organization", "Journal Name"]
    @faculty_list.each do |faculty|
      baseRow = [faculty.item.name, faculty.item.org_label, nil]
      if faculty.item.published_in.count == 0
          rows << baseRow
      else
          faculty.item.published_in.each do |journal|
              row = baseRow.clone
              row[2] = journal
              rows << row
          end
      end
    end
    rows
  end

  def teacher_for()
    rows = []
    rows << ["Name", "Organization", "Course Code", "Course Name"]
    @faculty_list.each do |faculty|
      baseRow = [faculty.item.name, faculty.item.org_label, nil, nil]
      if faculty.item.teacher_for.count == 0
          rows << baseRow
      else
          faculty.item.teacher_for.each do |course|
              row = baseRow.clone
              dash = course.index("-")
              if dash == nil
                  row[2] = course
                  row[3] = nil
              else
                  row[2] = course[0..(dash-1)]
                  row[3] = course[(dash+1)..-1].strip
              end
              rows << row
          end
      end
    end
    rows
  end

  def text_fields()
    rows = []
    rows << ["Name", "Organization", "Overview", "Teaching Overview", "Research Statement", "Research Overview", "Funded Research"]
    @faculty_list.each do |faculty|
      baseRow = [faculty.item.name, faculty.item.org_label, nil, nil, nil, nil, nil]
      row = baseRow.clone
      row[2] = safe_text(faculty.item.overview)
      row[3] = safe_text(faculty.item.teaching_overview)
      row[4] = safe_text(faculty.item.research_statement)
      row[5] = safe_text(faculty.item.research_overview)
      row[6] = safe_text(faculty.item.funded_research)
      rows << row
    end
    rows
  end

  def safe_text(text)
    clean_text = text.gsub('"', '')
    if clean_text.length > 500
      clean_text[0..500] + "(truncated)"
    else
      clean_text
    end
  end
end
