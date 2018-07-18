class PublicationHistory

  def initialize()
  end

  def for_org(org_id, org_name)
    history = {
      id: org_id,
      name: org_name,
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
end
