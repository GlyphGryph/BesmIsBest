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

ActiveRecord::Schema.define(version: 20160917170047) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "battles", force: :cascade do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.jsonb    "state"
    t.integer  "current_team_id"
    t.boolean  "started"
  end

  create_table "characters", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "world_id"
    t.integer  "xx"
    t.integer  "yy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companions", force: :cascade do |t|
    t.string   "image"
    t.integer  "hp"
    t.integer  "ap"
    t.integer  "max_hp"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "equipped_moves", force: :cascade do |t|
    t.string   "move_id"
    t.integer  "spirit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "known_moves", force: :cascade do |t|
    t.string   "move_id"
    t.integer  "spirit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spirits", force: :cascade do |t|
    t.string   "image"
    t.integer  "health"
    t.integer  "time_units"
    t.integer  "max_health"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb    "buffs"
    t.jsonb    "debuffs"
    t.jsonb    "poisons"
    t.integer  "species_id"
  end

  create_table "team_memberships", force: :cascade do |t|
    t.integer "team_id"
    t.integer "spirit_id"
    t.integer "position"
    t.index ["team_id", "spirit_id"], name: "index_team_memberships_on_team_id_and_spirit_id", unique: true, using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.integer  "character_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.jsonb    "state"
    t.integer  "battle_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "worlds", force: :cascade do |t|
    t.jsonb    "map"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
