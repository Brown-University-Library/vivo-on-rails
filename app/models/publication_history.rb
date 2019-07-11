class PublicationHistory
  # Returns the publication history for a given organization in a format
  # suitable for a Treemap visualization in D3.
  #
  # The returned hash includes a matrix with the data (each row represents
  # a year, and its values the counts for each faculty for that year),
  # an array of years with data, and an array of the columns represented
  # in the matrix, and array with details about each faculty.
  def self.treemap(id)
    # Get the publication history...
    history = self._history(id)

    # Initialize an array to store the yearly totals by faculty.
    # Each row in the array represents a year. Each row has individual keys
    # for each faculty in the history.
    #
    #   matrix = [
    #     {year: 2010, id1: 0, id2: 0, ..., idN: 0, total: 0},
    #     ...
    #     {year: 2018, id1: 0, id2: 0, ..., idN: 0, total: 0}
    #   ]
    #
    matrix = []
    for i in history[:min_year]..history[:max_year]
      row = {year: i, total: 0}
      history[:faculty].each do |faculty|
        key = faculty[:vivo_id]
        row[key] = 0
      end
      matrix << row
    end

    # Populate the counts for each year/faculty in the matrix (in columns)
    # and details about each faculty (in nodes)
    columns = []
    nodes = []
    history[:faculty].each do |faculty|
      next if faculty[:pubs].count == 0
      # keep track of faculty with publications
      columns << faculty[:vivo_id]
      # and their details
      node = {
        faculty_id: faculty[:vivo_id],
        name: faculty[:name],
        group: faculty[:group]
      }
      nodes << node

      # and process the publications for this faculty
      faculty[:pubs].each do |pub|
        offset = pub[:year].to_i - history[:min_year]
        year_data = matrix[offset]
        id = faculty[:vivo_id]
        year_data[id] = pub[:count]         # count for this year/faculty
        year_data[:total] += pub[:count]    # total for this year
      end
    end

    # Extract the years with data from the matrix (e.g. remove years without
    # publications)
    pubMatrix = []
    years = []
    matrix.each do |row|
      if row[:total] > 0
        years << row[:year].to_s
        pubMatrix << row
      end
    end

    return {matrix: pubMatrix, years: years, columns: columns, nodes: nodes}
  end

  # Returns a comma separated value representation of the treemap.
  def self.treemap_csv(id)
    treemap = self.treemap(id)
    text = []

    # Line 1: headers
    line = ["year", "year_total"]
    treemap[:columns].each do |col|
      line << col
    end
    text << line.join(",")

    # Line 2-N: data for each year
    treemap[:matrix].each do |row|
      line = []
      row.keys.each do |key|
        line << row[key]
      end
      text << line.join(",")
    end
    text.join("\n")
  end

  # Returns a hash with the publication history for a given organization.
  # The hash has the following structure:
  #
  #   {
  #     id: org_id,
  #     min_year: nnnn,     // oldest year of publication
  #     max_year: nnnn,     // most recent year of publication
  #     faculty: [          // array of faculty publication summary
  #       {
  #         id: faculty_id,
  #         name: faculty_name,
  #         pubs: [ {year: nnnn, count: N}, ..., {year: nnnn, count: N}]
  #       },
  #       ...
  #     ]
  #   }
  #
  # (This is a private method.)
  def self._history(org_id)
    history = {
      id: org_id,
      min_year: nil,
      max_year: nil,
      faculty: []
    }

    # Process each member of the organization...
    organization = Organization.load_from_solr(org_id)
    organization.faculty_list.each do |faculty|
      next if faculty == nil || faculty.item.contributor_to.count == 0

      # Calculate the number of publications by year for
      # this faculty member. pubs_by_year will be a hash
      # with the following structure:
      #   {
      #     :"year1" => n1,
      #     :"year2" => n2
      #   }
      pubs_by_year = {}
      faculty.item.contributor_to.each do |pub|
        next if pub.year == nil             # skip it
        next if pub.year > Date.today.year  # skip future publications (most likely bad data)
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

      # Create a hash to represent the summary for this faculty.
      # Notice that we turn the hash of publications by year
      # into an array in the form year:
      #
      #   [{year: year1, count: n1}, {year: year2, count: n2}]
      #
      faculty_summary = {
        id: faculty.item.id,
        vivo_id: faculty.item.vivo_id,
        name: faculty.item.name,
        pubs: pubs_by_year.map {|k,v| {year: k.to_s, count: v}},
        group: faculty.item.title
      }

      # add this faculty data to our history hash
      history[:faculty] << faculty_summary
    end

    history
  end
end
