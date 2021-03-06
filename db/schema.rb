# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190517130200) do

  create_table "book_covers", force: :cascade do |t|
    t.integer  "jacket_id"
    t.string   "firstname",  limit: 60
    t.string   "lastname",   limit: 90
    t.string   "shortID",    limit: 8
    t.string   "title",      limit: 255
    t.integer  "pub_date"
    t.string   "image",      limit: 255
    t.string   "role",       limit: 20
    t.string   "dept",       limit: 155
    t.string   "dept2",      limit: 255
    t.string   "dept3",      limit: 255
    t.string   "active",     limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "book_covers", ["pub_date"], name: "index_book_covers_on_pub_date"

  create_table "reports", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",        limit: 100
    t.text     "description"
    t.text     "definition"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports", ["id"], name: "index_reports_on_id"
  add_index "reports", ["name"], name: "index_reports_on_name"
  add_index "reports", ["user_id"], name: "index_reports_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "eppn",         limit: 100
    t.string   "display_name", limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["eppn"], name: "index_users_on_eppn"
  add_index "users", ["id"], name: "index_users_on_id"

end
