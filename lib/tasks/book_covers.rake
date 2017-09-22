require "./app/models/book_cover.rb"
namespace :vivo do
  desc "Tests the book covers fetch code"
  task :book_covers => :environment do
    pages = BookCoverModel.get_all_paginated("http://test", 6)
    puts pages
  end
end
