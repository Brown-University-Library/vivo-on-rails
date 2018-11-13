require "./app/models/book_cover.rb"
namespace :vivo do
  desc "Initializes the book cover cache with default data"
  task :book_covers_cache_init => :environment do
    BookCoverModel.init_default_data()
  end

  desc "Imports a tab delimited file with book cover data"
  task :book_covers_import, [:file_name] => :environment do |cmd, args|
    file_name = args[:file_name]
    if file_name == nil
      abort "Must provide file to import"
    end
    BookCoverModel.import_file(file_name)
  end

  desc "Deletes the data in the book cover table"
  task :book_covers_delete_all  => :environment do |cmd, args|
    BookCoverModel.delete_all!
  end
end
