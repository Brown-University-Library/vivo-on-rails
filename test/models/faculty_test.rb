require "minitest/autorun"
require "byebug"
require "./app/models/faculty.rb"
class QueryTest < Minitest::Test
  def test_all
    assert_equal 100, Faculty.all.count
  end

  def test_one
    id = "jhogansc"
    faculty = Faculty.get_one(id)
    assert_equal "Joseph_Hogan@brown.edu", faculty.email
  end

  def test_to_json
    id = "jhogansc"
    id = "bgenberg"
    faculty = Faculty.get_one(id)
    json = JSON.pretty_generate(JSON.parse(faculty.to_json))
    # File.write(id+".json", json.to_s)
  end
end
