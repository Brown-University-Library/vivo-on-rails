require "minitest/autorun"
require "byebug"
require "./app/models/model_utils.rb"

class ModelUtilsTest < Minitest::Test
  def test_valid_thumbnail_url
    # valid path with a root url
    file_path = "/file/n77201/photo.jpg"
    url = ModelUtils.thumbnail_url(file_path, "http://test")
    assert_equal "http://test/profile-images/772/01/photo.jpg", url

    # valid ID (3 chars)
    file_path = "/file/n65/10312.jpg" # jrovan
    url = ModelUtils.thumbnail_url(file_path)
    assert_equal "/profile-images/65/10312.jpg", url

    # valid ID (4 chars)
    file_path = "/file/n876/bruggeman_hugo.png"
    url = ModelUtils.thumbnail_url(file_path)
    assert_equal "/profile-images/876/bruggeman_hugo.png", url

    # valid ID (5 chars)
    file_path = "/file/n4165/eggertsson_gauti.png"
    url = ModelUtils.thumbnail_url(file_path)
    assert_equal "/profile-images/416/5/eggertsson_gauti.png", url

    # valid ID (6 characters)
    file_path = "/file/n15838/jk17.jpg"
    url = ModelUtils.thumbnail_url(file_path)
    assert_equal "/profile-images/158/38/jk17.jpg", url

    # valid ID (7 characters)
    file_path = "/file/n132159/10177.jpg" # pruberto
    url = ModelUtils.thumbnail_url(file_path)
    assert_equal "/profile-images/132/159/10177.jpg", url
  end

  def test_invalid_thumbnail_url
    # No ID provided
    file_path = "/file/photo.jpg"
    url = ModelUtils.thumbnail_url(file_path)
    assert_nil url

    # No file name provided
    file_path = "/file/n1234/"
    url = ModelUtils.thumbnail_url(file_path)
    assert_nil url

    # Does not start with /
    file_path = "file/n1234/n12345/photo.jpg"
    url = ModelUtils.thumbnail_url(file_path)
    assert_nil url

    # ID too short
    url = ModelUtils.thumbnail_url("/file/n/photo.jpg")
    assert_nil url
    url = ModelUtils.thumbnail_url("/file/n1/photo.jpg")
    assert_nil url

    # ID too long
    url = ModelUtils.thumbnail_url("/file/n1234567/photo.jpg")
    assert_nil url
  end
end
