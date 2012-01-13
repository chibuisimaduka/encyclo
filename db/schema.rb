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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120113173220) do

  create_table "books", :force => true do |t|
    t.string   "name"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "descriptions", :force => true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
  end

  create_table "documents", :force => true do |t|
    t.string   "name"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "content"
    t.float    "rank"
    t.text     "description"
  end

  create_table "documents_entities", :id => false, :force => true do |t|
    t.integer "document_id"
    t.integer "entity_id"
  end

  create_table "entities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rank"
    t.integer  "num_votes",  :default => 0
    t.integer  "tag_id"
  end

  create_table "entities_tags", :id => false, :force => true do |t|
    t.integer "entity_id"
    t.integer "tag_id"
  end

  create_table "entity_similarities", :force => true do |t|
    t.integer  "coefficient"
    t.integer  "entity_id"
    t.integer  "other_entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
    t.string   "image"
  end

  create_table "images_tags", :id => false, :force => true do |t|
    t.integer "image_id"
    t.integer "tag_id"
  end

  create_table "movies", :force => true do |t|
    t.string   "name"
    t.integer  "year"
    t.integer  "duration"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ranking_elements", :force => true do |t|
    t.integer  "ranking_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "record_id"
    t.integer  "rating"
  end

  create_table "rankings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "songs", :force => true do |t|
    t.string   "name"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
