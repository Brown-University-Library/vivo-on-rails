require "minitest/autorun"
require "byebug"
require "./app/models/organization.rb"

class OrganizationTest < Minitest::Test
  def test_get_one
    org = Organization.get_one("org-brown-univ-dept668")
    assert_equal org.name, "Egyptology and Assyriology"
    assert_equal true, org.people.count > 0
  end
end
