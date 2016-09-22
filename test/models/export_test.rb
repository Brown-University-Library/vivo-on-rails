# require "minitest/autorun"
# require "byebug"
# require "./app/models/export.rb"
# class QueryTest < Minitest::Test
#   def test_faculty_list
#     triples = Export.faculty_list
#     assert_equal 10, triples.count
#   end
#
#   def test_faculty_one
#     uri = "http://vivo.brown.edu/individual/jhogansc"
#     triples = Export.faculty_one(uri)
#     byebug
#     assert_equal 10, triples.count
#   end
# end
