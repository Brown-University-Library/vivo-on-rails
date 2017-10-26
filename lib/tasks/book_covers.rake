require "./app/models/book_cover.rb"
namespace :vivo do
  desc "Initializes the book cover cache with default data"
  task :book_cover_cache_init => :environment do
    BookCoverModel.init_default_data()
  end
end
