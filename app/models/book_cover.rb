class BookCoverModel
  attr_accessor :author_first, :author_last, :author_id, :author_url,
    :title, :pub_date, :image
  BASE_PATH = "https://vivo.brown.edu/themes/rab/images/books"

  def self.get_all(author_base_url)
    all = []

    item = BookCoverModel.new()
    item.author_first = "James"
    item.author_last = "Allen"
    item.author_id = "jallen"
    item.title = "Middle Egyptian Literature: Eight Literary Works of the Middle Kingdom"
    item.pub_date = "2015"
    item.image = "#{BASE_PATH}/Allen_MiddleEgyptianLiterature.jpg"
    all << item

    item = BookCoverModel.new()
    item.author_first = "Peter"
    item.author_last = "Andreas"
    item.author_id = "pandreas"
    item.title = "Rebel Mother: My Childhood Chasing the Revolution"
    item.pub_date = "2017"
    item.image = "#{BASE_PATH}/Andreas_RebelMother.jpg"
    all << item

    item = BookCoverModel.new()
    item.author_first = "Richard"
    item.author_last = "Arenber"
    item.author_id = "rarenber"
    item.title = "Defending the Filibuster: The Soul of the Senate, Revised and Updated"
    item.pub_date = "2014"
    item.image = "#{BASE_PATH}/Arenberg_DefendingTheFilibuster.jpg"
    all << item

    item = BookCoverModel.new()
    item.author_first = "Johanna"
    item.author_last = "Hanink"
    item.author_id = "jhanink"
    item.title = "The Classical Debt: Greek Antiquity in an Era of Austerity"
    item.pub_date = "2017"
    item.image = "#{BASE_PATH}/Hanink_ClassicalDebt.jpg"
    all << item

    # Calculate the author URL
    all.each do |item|
      item.author_url = author_base_url + item.author_id
    end

    all
  end
end
