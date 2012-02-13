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

ActiveRecord::Schema.define(:version => 20120213040436) do

  create_table "association_definitions", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "associated_entity_id"
    t.boolean  "entity_has_many"
    t.boolean  "associated_entity_has_many"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nested_entity_id"
  end

  create_table "associations", :force => true do |t|
    t.integer  "association_definition_id"
    t.integer  "entity_id"
    t.integer  "associated_entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_implicit"
  end

  create_table "components", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "associated_entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "concurring_users_delete_requests", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "delete_request_id"
  end

  create_table "delete_requests", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "destroyable_id"
    t.string   "destroyable_type"
    t.boolean  "considered_destroyed"
  end

  create_table "document_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "documents", :force => true do |t|
    t.string   "name"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "content"
    t.float    "rank"
    t.text     "description"
    t.integer  "document_type_id"
    t.integer  "language_id"
  end

  create_table "documents_entities", :id => false, :force => true do |t|
    t.integer "document_id"
    t.integer "entity_id"
  end

  create_table "edit_requests", :force => true do |t|
    t.integer  "editable_id"
    t.string   "editable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rank"
    t.integer  "tag_id"
    t.integer  "parent_id"
    t.boolean  "is_leaf"
    t.integer  "component_id"
    t.integer  "user_id"
  end

  create_table "entities_ancestors", :id => false, :force => true do |t|
    t.integer "entity_id"
    t.integer "ancestor_id"
  end

  create_table "entity_refs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
    t.integer  "predicate_id"
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
    t.float    "rank"
    t.string   "source"
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "names", :force => true do |t|
    t.string   "value"
    t.integer  "language_id"
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opposing_users_delete_requests", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "delete_request_id"
  end

  create_table "possible_document_types", :force => true do |t|
    t.integer  "document_id"
    t.integer  "document_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "possible_name_spellings", :force => true do |t|
    t.string   "spelling"
    t.integer  "name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "predicate_items", :force => true do |t|
    t.integer  "predicate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "user_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rankable_id"
    t.string   "rankable_type"
  end

  create_table "sources", :force => true do |t|
    t.string   "url"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subentities", :force => true do |t|
    t.integer  "entity_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_many"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_ip_address"
  end

  create_table "users_edit_requests", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "edit_request_id"
  end

end
