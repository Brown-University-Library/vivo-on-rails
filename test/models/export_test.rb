require "minitest/autorun"
require "byebug"
require "./app/models/export.rb"

class ExportTest < Minitest::Test
  # def test_faculty_one
  #   uri = "http://vivo.brown.edu/individual/jhogansc"
  #   triples = Export.faculty_one(uri)
  #   puts "#{triples.count} triples found"
  #   File.write("./export.ttl", triples.join(" . \n"))
  # end
end
