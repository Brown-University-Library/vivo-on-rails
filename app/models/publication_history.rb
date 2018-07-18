class PublicationHistory

  def initialize()
  end

  def self.for_org(org_id)
    history = {
      id: org_id,
      min_year: nil,
      max_year: nil,
      faculty: []
    }

    processedFaculty = []
    organization = Organization.load_from_solr(org_id)
    organization.item.people.each do |member|
      faculty = Faculty.load_from_solr(member.vivo_id)
      next if faculty == nil
      next if processedFaculty.include?(faculty.item.vivo_id)

      processedFaculty << faculty.item.vivo_id

      if faculty.item.contributor_to.count > 0
        pubs_by_year = {}
        faculty.item.contributor_to.each do |pub|
          next if pub.year == nil # skip it
          key = pub.year.to_s
          if pubs_by_year[key] == nil
            pubs_by_year[key] = 1
          else
            pubs_by_year[key] += 1
          end

          # Update the min/max year range
          if history[:min_year] == nil || pub.year < history[:min_year]
            history[:min_year] = pub.year
          end
          if history[:max_year] == nil || pub.year > history[:max_year]
            history[:max_year] = pub.year
          end
        end

        faculty_history = {
          id: faculty.item.id,
          vivo_id: faculty.item.vivo_id,
          name: faculty.item.name,
          pubs: []
        }
        # Do I need to sort desc by year?
        pubs_by_year.each do |key,value|
          faculty_history[:pubs] << {year: key.to_s, count: value}
        end

        history[:faculty] << faculty_history
      end
    end
    history
  end

  def self.matrix_for_org(id)
    # Get the publication history...
    data = self.for_org(id)

    # Initialize the matrix rows (years) / columns (faculty)
    matrix = []
    for i in data[:min_year]..data[:max_year]
      row = {year: i, total: 0}
      data[:faculty].each do |faculty|
        key = faculty[:vivo_id]
        row[key] = 0
      end
      matrix << row
    end

    # Populate the matrix with the counts for each year/faculty
    columns = []
    data[:faculty].each do |faculty|
      if faculty[:pubs].count > 0
        columns << faculty[:vivo_id]
      end
      faculty[:pubs].each do |pub|
        offset = pub[:year].to_i - data[:min_year]
        row = matrix[offset]
        key = faculty[:vivo_id]
        row[key] = pub[:count]
        row[:total] += pub[:count]
      end
    end

    # Only use the years with data
    pubMatrix = []
    years = []
    matrix.each do |row|
      if row[:total] > 0
        years << row[:year].to_s
        pubMatrix << row
      end
    end

    [pubMatrix, years, columns]
  end
end
