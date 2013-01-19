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

ActiveRecord::Schema.define(:version => 20130118062708) do

  create_table "apns_devices", :force => true do |t|
    t.integer  "player_id",    :null => false
    t.integer  "rapns_app_id", :null => false
    t.string   "device_token", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "apns_devices", ["device_token"], :name => "index_apns_devices_on_device_token", :unique => true
  add_index "apns_devices", ["player_id"], :name => "index_apns_devices_on_player_id"
  add_index "apns_devices", ["rapns_app_id"], :name => "index_apns_devices_on_rapns_app_id"

  create_table "games", :force => true do |t|
    t.integer  "dgs_game_id",   :null => false
    t.string   "opponent_name"
    t.integer  "player_id",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "games", ["dgs_game_id"], :name => "index_games_on_dgs_game_id"
  add_index "games", ["player_id"], :name => "index_games_on_player_id"

  create_table "players", :force => true do |t|
    t.integer  "dgs_user_id",     :null => false
    t.datetime "last_checked_at", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "players", ["dgs_user_id"], :name => "index_players_on_dgs_user_id", :unique => true
  add_index "players", ["last_checked_at"], :name => "index_players_on_last_checked_at"

  create_table "rapns_apps", :force => true do |t|
    t.string   "name",                       :null => false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections", :default => 1, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "type",                       :null => false
    t.string   "auth_key"
  end

  create_table "rapns_feedback", :force => true do |t|
    t.string   "device_token", :limit => 64, :null => false
    t.datetime "failed_at",                  :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "app"
  end

  add_index "rapns_feedback", ["device_token"], :name => "index_rapns_feedback_on_device_token"

  create_table "rapns_notifications", :force => true do |t|
    t.integer  "badge"
    t.string   "device_token",      :limit => 64
    t.string   "sound",                            :default => "default"
    t.string   "alert"
    t.text     "data"
    t.integer  "expiry",                           :default => 86400
    t.boolean  "delivered",                        :default => false,     :null => false
    t.datetime "delivered_at"
    t.boolean  "failed",                           :default => false,     :null => false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description", :limit => 255
    t.datetime "deliver_after"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.boolean  "alert_is_json",                    :default => false
    t.string   "type",                                                    :null => false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",                 :default => false,     :null => false
    t.text     "registration_ids"
    t.integer  "app_id",                                                  :null => false
    t.integer  "retries",                          :default => 0
  end

  add_index "rapns_notifications", ["app_id", "delivered", "failed", "deliver_after"], :name => "index_rapns_notifications_multi"

end
