require "minitest/autorun"
require "byebug"
require "./app/models/model_utils.rb"

class ModelUtilsTest < Minitest::Test
  def test_thumbnail_url
    # a valid path
    file_path = "/file/n77201/photo.jpg"
    url = ModelUtils.thumbnail_url(file_path)
    assert_equal url, "/profile-images/772/01/photo.jpg"

    # a valid path with a root url
    file_path = "/file/n77201/photo.jpg"
    url = ModelUtils.thumbnail_url(file_path, "http://test")
    assert_equal url, "http://test/profile-images/772/01/photo.jpg"

    # an invalid path (no ID provided)
    file_path = "/file/photo.jpg"
    url = ModelUtils.thumbnail_url(file_path)
    assert_nil url

    # an invalid path (ID is too short)
    file_path = "/file/n1234/photo.jpg"
    url = ModelUtils.thumbnail_url(file_path)
    assert_nil url

    # an invalid path (no file name provided)
    file_path = "/file/n1234/"
    url = ModelUtils.thumbnail_url(file_path)
    assert_nil url

    # an invalid path (does not start with /)
    file_path = "file/n1234/n12345/photo.jpg"
    url = ModelUtils.thumbnail_url(file_path)
    assert_nil url
  end
end
