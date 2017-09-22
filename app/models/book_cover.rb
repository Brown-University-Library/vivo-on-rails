class BookCoverModel
  attr_accessor :author_first, :author_last, :author_id, :author_url,
    :title, :pub_date, :image
  BASE_PATH = "https://vivo.brown.edu/themes/rab/images/books"

  @@covers = nil
  @@covers_paginated = nil

  def self.get_all_paginated(author_base_url, page_size)
    @@covers_paginated ||= begin
      Rails.logger.info "Calculating paginated covers..."
      covers = get_all(author_base_url)
      pages = []
      page = []
      covers.each do |cover|
        page << cover
        if page.count == page_size
          pages << page
          page = []
        end
      end
      if page.count > 0
        pages << page
      end
      pages
    end
  end

  def self.db_pool()
    pool = ActiveRecord::Base.establish_connection(
      :adapter  => "mysql2",
      :host     => ENV["BOOK_COVER_HOST"],
      :database => ENV["BOOK_COVER_DB"],
      :username => ENV["BOOK_COVER_USER"],
      :password => ENV["BOOK_COVER_PASSWORD"]
    )
  end

  def self.get_all(author_base_url)
    @@covers ||= begin
      covers = []
      if ENV["BOOK_COVER_HOST"] != nil
        Rails.logger.info "Fetching covers from the database..."
        sql = <<-END_SQL.gsub(/\n/, '')
          SELECT jacket_id, firstname, lastname, shortID, title, pub_date,
          image, dept, dept2, dept3, active
          FROM book_jackets
          ORDER BY pub_date DESC
        END_SQL
        pool = db_pool()
        rows = pool.connection.exec_query(sql)
        rows.each do |row|
          cover = BookCoverModel.new()
          cover.author_first = row['firstname']
          cover.author_last = row['lastname']
          cover.author_id = row['shortID']
          cover.author_url = "#{author_base_url}#{row['shortID']}"
          cover.title = row['title']
          cover.pub_date = row['pub_date']
          cover.image = "#{BASE_PATH}/#{row['image']}"
          covers << cover
        end
        pool.disconnect!
      end
      covers
    end
  end
end
