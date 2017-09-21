require "./app/models/book_cover.rb"
class HomeController < ApplicationController
  def about
  end

  def faq
  end

  def help
  end

  def index
    base_author_url = display_show_url("")
    @bookCovers = BookCoverModel.get_all(base_author_url)
  end

  def publications
  end

  def roadmap
  end

  def termsofuse
  end
end
