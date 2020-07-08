# -*- encoding : utf-8 -*-
class CreateBookCovers < ActiveRecord::Migration[4.2]
  def self.up
    options = nil
    if Rails.env.production?
      options = 'DEFAULT CHARSET=utf8'
    end
    create_table(:book_covers, :options => options) do |t|
      # structure mimics legacy table
      t.integer :jacket_id
      t.string :firstname, limit: 60
      t.string :lastname, limit: 90
      t.string :shortID, limit: 8
      t.string :title, limit: 255
      t.integer :pub_date
      t.string :image, limit: 255
      t.string :role, limit: 20
      t.string :dept, limit: 155
      t.string :dept2, limit: 255
      t.string :dept3, limit: 255
      t.string :active, limit: 1
      t.timestamps
    end

    add_index :book_covers, :pub_date
  end

  def self.down
    drop_table :book_covers
  end
end
