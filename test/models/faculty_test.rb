require "minitest/autorun"
require "byebug"
require "./app/models/faculty.rb"

class FacultyTest < Minitest::Test
  def test_all
    assert_equal 100, Faculty.all.count
  end

  def test_all_uris
    uris = Faculty.all_uris
    assert_equal 100, uris.count
    assert_equal true, uris[0].start_with?("http://vivo.brown.edu/individual")
  end

  def test_get_batch
    uris = Faculty.all_uris
    batch = [uris[0], uris[1]]
    faculty = Faculty.get_batch(batch)
    assert_equal 2, faculty.count
    assert_equal true, faculty.any? {|f| f.uri == uris[1]}
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
end
