require "./app/models/book_cover.rb"
class HomeController < ApplicationController
  def about
  end

  def faq
  end

  def help
  end

  def index
    m = BookCoverModel.new()
    m.test_db()
    
    page_size = 4 # Must be divisible by 12 to line up with Bootstrap's column layout
    @carouselColumn = "col-xs-#{12/page_size}"
    base_author_url = display_show_url("")
    @bookCoversPaginated = BookCoverModel.get_all_paginated(base_author_url, page_size)
  end

  def publications
  end

  def roadmap
  end

  def termsofuse
  end
end
