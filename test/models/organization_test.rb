require "minitest/autorun"
require "byebug"
require "./app/models/organization.rb"

class OrganizationTest < Minitest::Test
  def test_all_uris
    uris = Organization.all_uris
    assert uris.count > 0
    assert uris.first.start_with?("http://vivo.brown.edu/individual/org-brown-univ")

    batch = [uris[0], uris[1]]
    orgs = Organization.get_batch(batch)
    assert batch.count == 2
  end

  def test_get_one
    org = Organization.get_one("org-brown-univ-dept668")
    assert_equal org.name, "Egyptology and Assyriology"
    assert org.people.count > 0
    assert org.people.any? {|p| p.id = "lbestock" }
  end
end
