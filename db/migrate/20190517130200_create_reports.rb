# -*- encoding : utf-8 -*-
class CreateReports < ActiveRecord::Migration[4.2]
  def self.up
    options = nil
    if Rails.env.production?
      options = 'DEFAULT CHARSET=utf8'
    end
    create_table(:reports, :options => options) do |t|
      t.integer :user_id
      t.string :name, limit: 100
      t.text :description
      t.text :definition
      t.timestamps
    end

    add_index :reports, :id
    add_index :reports, :user_id
    add_index :reports, :name
  end

  def self.down
    drop_table :reports
  end
end
