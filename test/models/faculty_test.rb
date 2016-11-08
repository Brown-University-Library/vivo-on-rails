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

  # def test_one
  #   id = "aspirito"
  #   faculty = Faculty.get_one_from_fuseki(id)
  # end

  # def test_to_json
  #   id = "jhogansc"
  #   id = "bgenberg"
  #   faculty = Faculty.get_one(id)
  #   byebug
  #   json = JSON.pretty_generate(JSON.parse(faculty.to_json))
  #   # File.write(id+".json", json.to_s)
  # end
end
