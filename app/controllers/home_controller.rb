require "./app/models/book_cover.rb"
class HomeController < ApplicationController
  def about
  end

  def faq
  end

  def help
  end

  def index
    page_size = 4
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
