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

ActiveRecord::Schema.define(:version => 20120426045358) do

  create_table "association_definitions", :force => true do |t|
    t.integer  "entity_id",                  :null => false
    t.integer  "associated_entity_id",       :null => false
    t.boolean  "entity_has_many",            :null => false
    t.boolean  "associated_entity_has_many", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nested_entity_id"
    t.integer  "user_id",                    :null => false
  end

  add_index "association_definitions", ["associated_entity_id"], :name => "fk_associated_entity"
  add_index "association_definitions", ["entity_id"], :name => "fk_entity"
  add_index "association_definitions", ["nested_entity_id"], :name => "fk_nested_entity"
  add_index "association_definitions", ["user_id"], :name => "user_id"

  create_table "associations", :force => true do |t|
    t.integer  "association_definition_id", :null => false
    t.integer  "entity_id",                 :null => false
    t.integer  "associated_entity_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                   :null => false
    t.float    "rank"
  end

  add_index "associations", ["associated_entity_id"], :name => "associated_entity_id"
  add_index "associations", ["association_definition_id", "associated_entity_id", "rank"], :name => "associations_def_associated_rank"
  add_index "associations", ["association_definition_id", "entity_id", "rank"], :name => "associations_def_entity_rank"
  add_index "associations", ["association_definition_id"], :name => "association_definition_id"
  add_index "associations", ["entity_id"], :name => "associations_entity_id"
  add_index "associations", ["user_id"], :name => "user_id"

  create_table "child_documents", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "components", :force => true do |t|
    t.integer  "entity_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    :null => false
  end

  add_index "components", ["entity_id"], :name => "entity_id"
  add_index "components", ["user_id"], :name => "user_id"

  create_table "concurring_users_delete_requests", :id => false, :force => true do |t|
    t.integer "user_id",           :null => false
    t.integer "delete_request_id", :null => false
  end

  add_index "concurring_users_delete_requests", ["delete_request_id"], :name => "delete_request_id"
  add_index "concurring_users_delete_requests", ["user_id", "delete_request_id"], :name => "concurring_users_delete_requests_i"
  add_index "concurring_users_delete_requests", ["user_id"], :name => "user_id"

  create_table "delete_requests", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "destroyable_id",       :null => false
    t.string   "destroyable_type",     :null => false
    t.boolean  "considered_destroyed", :null => false
  end

  create_table "documents", :force => true do |t|
    t.string   "name",              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "content",           :null => false
    t.float    "rank"
    t.text     "description",       :null => false
    t.integer  "language_id",       :null => false
    t.integer  "user_id",           :null => false
    t.integer  "documentable_id"
    t.string   "documentable_type", :null => false
    t.integer  "component_id"
  end

  add_index "documents", ["language_id"], :name => "documents_language"
  add_index "documents", ["user_id"], :name => "user_id"

  create_table "documents_entities", :id => false, :force => true do |t|
    t.integer "document_id", :null => false
    t.integer "entity_id",   :null => false
  end

  add_index "documents_entities", ["document_id", "entity_id"], :name => "documents_entities_i"
  add_index "documents_entities", ["document_id"], :name => "document_id"
  add_index "documents_entities", ["entity_id"], :name => "entity_id"

  create_table "edit_requests", :force => true do |t|
    t.integer  "editable_id",   :null => false
    t.string   "editable_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edit_requests", ["editable_type", "editable_id"], :name => "edit_request_editable_type_and_id"

  create_table "entities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rank"
    t.integer  "parent_id"
    t.integer  "component_id"
    t.integer  "user_id",           :null => false
    t.string   "freebase_id"
    t.boolean  "is_intermediate"
    t.float    "content_size_rank"
  end

  add_index "entities", ["component_id"], :name => "fk_component"
  add_index "entities", ["freebase_id"], :name => "freebase_id_fk"
  add_index "entities", ["parent_id", "component_id"], :name => "entity_parent_component"
  add_index "entities", ["parent_id"], :name => "fk_parent"
  add_index "entities", ["user_id"], :name => "fk_user"

  create_table "entities_ancestors", :id => false, :force => true do |t|
    t.integer "entity_id",   :null => false
    t.integer "ancestor_id", :null => false
  end

  add_index "entities_ancestors", ["ancestor_id"], :name => "ancestor_id"
  add_index "entities_ancestors", ["entity_id", "ancestor_id"], :name => "entities_ancestors_i"

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

  create_table "freebase_entities", :force => true do |t|
    t.string   "freebase_id"
    t.string   "freebase_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "freebase_entities", ["freebase_id"], :name => "freebase_id", :unique => true

  create_table "images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id",  :null => false
    t.string   "image",      :null => false
    t.float    "rank"
    t.string   "source"
    t.integer  "user_id",    :null => false
  end

  add_index "images", ["entity_id"], :name => "entity_id"
  add_index "images", ["user_id"], :name => "user_id"

  create_table "languages", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "names", :force => true do |t|
    t.string   "value",       :null => false
    t.integer  "language_id", :null => false
    t.integer  "entity_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "names", ["entity_id"], :name => "entity_id"
  add_index "names", ["language_id", "value", "entity_id"], :name => "name_autocomplete"
  add_index "names", ["language_id"], :name => "language_id"

  create_table "opposing_users_delete_requests", :id => false, :force => true do |t|
    t.integer "user_id",           :null => false
    t.integer "delete_request_id", :null => false
  end

  add_index "opposing_users_delete_requests", ["delete_request_id"], :name => "delete_request_id"
  add_index "opposing_users_delete_requests", ["user_id", "delete_request_id"], :name => "opposing_users_delete_requests_i"
  add_index "opposing_users_delete_requests", ["user_id"], :name => "user_id"

  create_table "predicate_items", :force => true do |t|
    t.integer  "predicate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.float    "value",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rankable_id",   :null => false
    t.string   "rankable_type", :null => false
  end

  add_index "ratings", ["user_id"], :name => "user_id"

  create_table "remote_documents", :force => true do |t|
    t.string   "url",        :null => false
    t.binary   "content",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remote_documents", ["url"], :name => "remote_url_i"

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

  create_table "user_documents", :force => true do |t|
    t.text     "content",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",          :null => false
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_ip_address"
    t.integer  "home_entity_id"
  end

  create_table "users_edit_requests", :id => false, :force => true do |t|
    t.integer "user_id",         :null => false
    t.integer "edit_request_id", :null => false
  end

  add_index "users_edit_requests", ["edit_request_id"], :name => "edit_request_id"
  add_index "users_edit_requests", ["user_id", "edit_request_id"], :name => "users_edit_requests_i"
  add_index "users_edit_requests", ["user_id"], :name => "user_id"

end
