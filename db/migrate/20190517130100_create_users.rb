# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration[4.2]
  def self.up
    options = nil
    if ENV['DATABASE_ADAPTER'] == "mysql2"
      options = 'DEFAULT CHARSET=utf8'
    end
    create_table(:users, :options => options) do |t|
      t.string :eppn, limit: 100
      t.string :display_name, limit: 100
      t.timestamps
    end

    add_index :users, :id
    add_index :users, :eppn
  end

  def self.down
    drop_table :users
  end
end
