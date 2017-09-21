require "./app/models/book_cover.rb"
class HomeController < ApplicationController
  def about
  end

  def faq
  end

  def help
  end

  def index
    @bookCovers = BookCoverModel.get_all()
  end

  def publications
  end

  def roadmap
  end

  def termsofuse
  end
end
