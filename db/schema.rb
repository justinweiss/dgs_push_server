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

ActiveRecord::Schema.define(version: 20150709000035) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "players", force: true do |t|
    t.integer  "dgs_user_id",     null: false
    t.datetime "last_checked_at", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "handle"
    t.index ["dgs_user_id"], :name => "index_players_on_dgs_user_id", :unique => true
    t.index ["handle"], :name => "index_players_on_handle"
    t.index ["last_checked_at"], :name => "index_players_on_last_checked_at"
  end

  create_table "rpush_apps", force: true do |t|
    t.string   "name",                                null: false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             default: 1, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "type",                                null: false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "apns_devices", force: true do |t|
    t.integer  "player_id",    null: false
    t.integer  "rpush_app_id", null: false
    t.string   "device_token", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["device_token"], :name => "index_apns_devices_on_device_token", :unique => true
    t.index ["player_id"], :name => "index_apns_devices_on_player_id"
    t.index ["rpush_app_id"], :name => "index_apns_devices_on_rpush_app_id"
    t.foreign_key ["player_id"], "players", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_apns_devices_player_id"
    t.foreign_key ["rpush_app_id"], "rpush_apps", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_apns_devices_rapns_app_id"
  end

  create_table "games", force: true do |t|
    t.integer  "dgs_game_id",   null: false
    t.string   "opponent_name"
    t.integer  "player_id",     null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["dgs_game_id"], :name => "index_games_on_dgs_game_id"
    t.index ["player_id"], :name => "index_games_on_player_id"
    t.foreign_key ["player_id"], "players", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_games_player_id"
  end

  create_table "rpush_feedback", force: true do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "app_id"
    t.index ["device_token"], :name => "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", force: true do |t|
    t.integer  "badge"
    t.string   "device_token",      limit: 64
    t.string   "sound",                        default: "default"
    t.string   "alert"
    t.text     "data"
    t.integer  "expiry",                       default: 86400
    t.boolean  "delivered",                    default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",                       default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "alert_is_json",                default: false
    t.string   "type",                                             null: false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",             default: false,     null: false
    t.text     "registration_ids"
    t.integer  "app_id",                                           null: false
    t.integer  "retries",                      default: 0
    t.string   "uri"
    t.datetime "fail_after"
    t.boolean  "processing",                   default: false,     null: false
    t.integer  "priority"
    t.text     "url_args"
    t.string   "category"
    t.index ["delivered", "failed"], :name => "index_rpush_notifications_multi"
  end

  create_table "sessions", force: true do |t|
    t.integer  "player_id"
    t.string   "cookie"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], :name => "index_sessions_on_player_id"
    t.foreign_key ["player_id"], "players", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "fk_sessions_player_id"
  end

end
