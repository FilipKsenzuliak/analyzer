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

ActiveRecord::Schema.define(version: 20161130101208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string   "tag"
    t.string   "clasification"
    t.string   "description"
    t.boolean  "original"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "logs", force: :cascade do |t|
    t.string   "text"
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "pattern_id"
  end

  add_index "logs", ["pattern_id"], name: "index_logs_on_pattern_id", using: :btree

  create_table "parsers", force: :cascade do |t|
    t.string   "name"
    t.string   "expression"
    t.boolean  "blacklist"
    t.string   "source_group"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "patterns", force: :cascade do |t|
    t.string   "text"
    t.string   "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "role"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
  end

end
