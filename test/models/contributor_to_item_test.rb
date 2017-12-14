require "minitest/autorun"
require "byebug"
require "./app/models/contributor_to_item.rb"

class ContributorToItemTest < Minitest::Test
  def test_comparisons

    a = ContributorToItem.new({date: "2017-01-01", title: "aaa"})
    b = ContributorToItem.new({date: "2017-01-01", title: "bbb"})
    c = ContributorToItem.new({date: "2017-01-01", title: "ccc"})
    d = ContributorToItem.new({date: "2016-01-01", title: "ccc"})
    e = ContributorToItem.new({date: "2015-01-01", title: "ccc"})

    # same year, sort by title ascending
    assert_equal a <=> b, -1    # less than
    assert_equal c <=> b, 1     # greater than
    assert_equal b <=> b, 0     # equal

    # sort by year (year 2016 sorted after year 2017)
    assert_equal c <=> d, -1    # less than
    assert_equal d <=> c, 1     # greater than
  end

  def test_sort
    array = []
    array << ContributorToItem.new({date: "2017-01-01", title: "ccc", uri: "c"})
    array << ContributorToItem.new({date: "2016-01-01", title: "ccc", uri: "d"})
    array << ContributorToItem.new({date: "2017-01-01", title: "bbb", uri: "b"})
    array << ContributorToItem.new({date: "2015-01-01", title: "ccc", uri: "e"})
    array << ContributorToItem.new({date: "2017-01-01", title: "aaa", uri: "a"})

    array.sort!
    assert_equal array[0].uri, "a"
    assert_equal array[1].uri, "b"
    assert_equal array[2].uri, "c"
    assert_equal array[3].uri, "d"
    assert_equal array[4].uri, "e"
  end

  def test_ignore_month_day
    array = []
    array << ContributorToItem.new({date: "1993-01-01", title: "Fiction, Bewitchment...", uri: "a"})
    array << ContributorToItem.new({date: "1993-11-01", title: "Sounding Out Ecphrasis.", uri: "b"})

    # Test that we are using the year of publication
    # (and not the full date with month/day of publication)
    #
    # In this example, even though item "b" was published more recently
    # (in November) we expect it to be sorted alphabetically after item "a"
    # (published in January).
    array.sort!
    assert_equal array[0].uri, "a"
    assert_equal array[1].uri, "b"
  end
end
