require "./app/models/model_utils.rb"

class OrganizationMemberItem
  # general_position is the predicate e.g. "http://vivoweb.org/ontology/core#FacultyPosition"
  # specific_position is the name e.g. "Chair of Biostatistics"
  # title is the combination of all specific_positions e.g.
  #   "Carole and Lawrence Sirovich Professor of Public Health,  Professor of Biostatistics,  Chair of Biostatistics"}
  attr_accessor :id, :faculty_uri, :label, :general_position, :specific_position
  def initialize(values = nil)
    ModelUtils.set_values_from_hash(self, values)
    @id = @faculty_uri
  end

  def vivo_id
    ModelUtils::vivo_id(@id)
  end

  def admin_position?
    (@general_position == "http://vivoweb.org/ontology/core#FacultyAdministrativePosition")
  end

  def sort_label
    (@label || "").upcase
  end

  def self.from_hash_array(values)
    members = values.map { |v| OrganizationMemberItem.new(v)}
    members.sort_by {|v| v.sort_label }
  end
end
