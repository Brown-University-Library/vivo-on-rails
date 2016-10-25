require "minitest/autorun"
require "byebug"
require "./app/models/faculty.rb"

class FacultyTest < Minitest::Test
  def test_all
    assert Faculty.all.count >= 100
  end

  def test_all_uris
    uris = Faculty.all_uris
    assert uris.count >= 100
    assert uris[0].start_with?("http://vivo.brown.edu/individual")
  end

  def test_get_batch
    uris = Faculty.all_uris
    batch = [uris[0], uris[1]]
    faculty = Faculty.get_batch(batch)
    assert_equal 2, faculty.count
    assert faculty.any? {|f| f.uri == uris[1]}
  end

  def test_one
    id = "jhogansc"
    faculty = Faculty.get_one(id)
    assert_equal "Joseph_Hogan@brown.edu", faculty.email
  end

  # def test_to_json
  #   id = "jhogansc"
  #   id = "bgenberg"
  #   faculty = Faculty.get_one(id)
  #   json = JSON.pretty_generate(JSON.parse(faculty.to_json))
  #   # File.write(id+".json", json.to_s)
  # end
  #

  # def test_to_json_for_solr4
  #   id = "bgenberg"
  #   faculty = Faculty.get_one(id)
  #   puts process_props(faculty, faculty.instance_variables, "")
  # end

  # def process_props(obj, props, prefix)
  #   str = "{\r\n"
  #   props.each do |p|
  #     # byebug
  #     p_name = p.to_s[1..-1]
  #     next if !obj.respond_to?(p_name)
  #     p_value = obj.send(p_name)
  #     json_name = prefix + p_name
  #     if p_value.class == Array
  #       str += "[\r\n"
  #       p_value.each do |pp|
  #         str += process_props(pp, pp.instance_variables, json_name + "_")
  #       end
  #       str += "\r\n]"
  #     else
  #       str += "\"#{json_name}\" : \"#{p_value}\", \r\n"
  #     end
  #   end
  #   str += "\r\n}"
  # end
end
