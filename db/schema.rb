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

ActiveRecord::Schema.define(version: 20160127133722) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_extensions", id: false, force: :cascade do |t|
    t.integer "account_id"
    t.string  "extension_name", null: false
  end

  add_index "account_extensions", ["account_id", "extension_name"], name: "index_account_extensions_on_account_id_and_extension_name", unique: true, using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "brand_id",   null: false
  end

  create_table "activities", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "payload"
    t.string   "scheme"
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "default_beacon_uuid"
    t.integer  "account_id"
    t.integer  "role",                   default: 0
    t.string   "correlation_id"
    t.boolean  "walkthrough",            default: false
  end

  add_index "admins", ["account_id"], name: "index_admins_on_account_id", using: :btree
  add_index "admins", ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true, using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "application_extensions", force: :cascade do |t|
    t.integer  "application_id"
    t.text     "configuration"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "extension_name", null: false
  end

  add_index "application_extensions", ["application_id", "extension_name"], name: "index_applications_extensions", unique: true, using: :btree
  add_index "application_extensions", ["application_id"], name: "index_application_extensions_on_application_id", using: :btree

  create_table "application_settings", force: :cascade do |t|
    t.integer  "application_id", null: false
    t.string   "extension_name", null: false
    t.string   "type",           null: false
    t.string   "key",            null: false
    t.text     "value"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "application_settings", ["application_id"], name: "index_application_settings_on_application_id", using: :btree

  create_table "applications", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "account_id"
    t.boolean  "test",       default: false
  end

  add_index "applications", ["account_id"], name: "index_applications_on_account_id", using: :btree

  create_table "applications_beacons", force: :cascade do |t|
    t.integer "application_id"
    t.integer "beacon_id"
  end

  add_index "applications_beacons", ["application_id", "beacon_id"], name: "applications_beacons_index", using: :btree

  create_table "applications_zones", force: :cascade do |t|
    t.integer "application_id"
    t.integer "zone_id"
  end

  add_index "applications_zones", ["application_id", "zone_id"], name: "applications_zones_index", using: :btree

  create_table "beacon_configs", force: :cascade do |t|
    t.integer  "beacon_id"
    t.text     "data"
    t.datetime "beacon_updated_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "beacon_configs", ["beacon_id"], name: "index_beacon_configs_on_beacon_id", using: :btree

  create_table "beacon_presence_stats", force: :cascade do |t|
    t.string  "proximity_id",             null: false
    t.date    "date",                     null: false
    t.integer "hour",                     null: false
    t.integer "users_count",  default: 0
  end

  create_table "beacon_proximity_fields", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "beacon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "beacon_proximity_fields", ["beacon_id"], name: "index_beacon_proximity_fields_on_beacon_id", using: :btree

  create_table "beacons", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.decimal  "lat",            precision: 9, scale: 6
    t.decimal  "lng",            precision: 9, scale: 6
    t.integer  "floor"
    t.integer  "account_id"
    t.integer  "zone_id"
    t.integer  "manager_id"
    t.string   "location"
    t.string   "protocol",                               default: "iBeacon"
    t.string   "vendor",                                 default: "Other"
    t.string   "proximity_uuid"
  end

  add_index "beacons", ["proximity_uuid", "account_id"], name: "index_beacons_on_proximity_uuid_and_account_id", unique: true, using: :btree

  create_table "brands", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coupon_images", force: :cascade do |t|
    t.integer  "coupon_id"
    t.string   "file"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "coupon_images", ["coupon_id"], name: "index_coupon_images_on_coupon_id", using: :btree

  create_table "coupons", force: :cascade do |t|
    t.string   "template"
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.integer  "activity_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "identifier_number"
    t.string   "unique_identifier_number"
    t.integer  "encoding_type"
    t.string   "button_font_color"
    t.string   "button_background_color"
    t.string   "button_label"
    t.string   "button_link"
  end

  add_index "coupons", ["activity_id"], name: "index_coupons_on_activity_id", using: :btree
  add_index "coupons", ["template"], name: "index_coupons_on_template", using: :btree

  create_table "custom_attributes", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "activity_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "custom_attributes", ["activity_id"], name: "index_custom_attributes_on_activity_id", using: :btree

  create_table "ext_analytics_beacons_dwell_time_aggregations", force: :cascade do |t|
    t.integer "ext_analytics_dwell_time_aggregation_id", null: false
    t.integer "beacon_id",                               null: false
  end

  add_index "ext_analytics_beacons_dwell_time_aggregations", ["ext_analytics_dwell_time_aggregation_id", "beacon_id"], name: "ext_analytics_dta_beacon_idx", using: :btree

  create_table "ext_analytics_beacons_events", id: false, force: :cascade do |t|
    t.integer "ext_analytics_event_id", null: false
    t.integer "beacon_id",              null: false
  end

  add_index "ext_analytics_beacons_events", ["ext_analytics_event_id", "beacon_id"], name: "ext_analytics_beacons_events_idx", using: :btree

  create_table "ext_analytics_beacons_zones", id: false, force: :cascade do |t|
    t.integer "ext_analytics_event_id", null: false
    t.integer "zone_id",                null: false
  end

  add_index "ext_analytics_beacons_zones", ["ext_analytics_event_id", "zone_id"], name: "ext_analytics_beacons_zones_idx", using: :btree

  create_table "ext_analytics_dwell_time_aggregations", force: :cascade do |t|
    t.integer  "application_id",             null: false
    t.string   "proximity_id",               null: false
    t.string   "user_id"
    t.date     "date",                       null: false
    t.datetime "timestamp",                  null: false
    t.integer  "dwell_time",     default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "ext_analytics_dwell_time_aggregations", ["application_id"], name: "index_ext_analytics_dwell_time_aggregations_on_application_id", using: :btree
  add_index "ext_analytics_dwell_time_aggregations", ["date"], name: "index_ext_analytics_dwell_time_aggregations_on_date", using: :btree
  add_index "ext_analytics_dwell_time_aggregations", ["proximity_id"], name: "index_ext_analytics_dwell_time_aggregations_on_proximity_id", using: :btree
  add_index "ext_analytics_dwell_time_aggregations", ["timestamp"], name: "index_ext_analytics_dwell_time_aggregations_on_timestamp", using: :btree
  add_index "ext_analytics_dwell_time_aggregations", ["user_id"], name: "index_ext_analytics_dwell_time_aggregations_on_user_id", using: :btree

  create_table "ext_analytics_dwell_time_aggregations_zones", force: :cascade do |t|
    t.integer "ext_analytics_dwell_time_aggregation_id", null: false
    t.integer "zone_id",                                 null: false
  end

  add_index "ext_analytics_dwell_time_aggregations_zones", ["ext_analytics_dwell_time_aggregation_id", "zone_id"], name: "ext_analytics_dta_zone_idx", using: :btree

  create_table "ext_analytics_events", force: :cascade do |t|
    t.integer  "application_id", null: false
    t.string   "proximity_id",   null: false
    t.string   "user_id"
    t.string   "event_type",     null: false
    t.integer  "action_id"
    t.datetime "timestamp",      null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "ext_analytics_events", ["application_id"], name: "index_ext_analytics_events_on_application_id", using: :btree
  add_index "ext_analytics_events", ["event_type"], name: "index_ext_analytics_events_on_event_type", using: :btree
  add_index "ext_analytics_events", ["proximity_id"], name: "index_ext_analytics_events_on_proximity_id", using: :btree
  add_index "ext_analytics_events", ["timestamp"], name: "index_ext_analytics_events_on_timestamp", using: :btree
  add_index "ext_analytics_events", ["user_id"], name: "index_ext_analytics_events_on_user_id", using: :btree

  create_table "ext_kontakt_io_beacon_assignments", force: :cascade do |t|
    t.integer "beacon_id", null: false
    t.string  "unique_id", null: false
  end

  add_index "ext_kontakt_io_beacon_assignments", ["beacon_id"], name: "index_ext_kontakt_io_beacon_assignments_on_beacon_id", using: :btree

  create_table "ext_kontakt_io_mapping", force: :cascade do |t|
    t.string  "target_type"
    t.integer "target_id"
    t.string  "kontakt_uid"
  end

  create_table "ext_neighbours_zone_neighbours", force: :cascade do |t|
    t.integer  "source_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ext_presence_beacon_presences", force: :cascade do |t|
    t.integer  "beacon_id"
    t.string   "client_id"
    t.datetime "timestamp"
    t.boolean  "present",    default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "ext_presence_zone_presences", force: :cascade do |t|
    t.integer  "zone_id"
    t.string   "client_id"
    t.datetime "timestamp"
    t.boolean  "present",    default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "extension_settings", force: :cascade do |t|
    t.integer "account_id",     null: false
    t.string  "extension_name", null: false
    t.string  "key",            null: false
    t.string  "value"
  end

  create_table "mobile_devices", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "push_token"
    t.integer  "os",                             null: false
    t.integer  "environment",     default: 1,    null: false
    t.boolean  "active",          default: true, null: false
    t.datetime "last_sign_in_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "correlation_id"
  end

  add_index "mobile_devices", ["active"], name: "index_mobile_devices_on_active", using: :btree
  add_index "mobile_devices", ["user_id"], name: "index_mobile_devices_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "scopes",       default: "", null: false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       null: false
    t.string   "password_salt"
    t.string   "password_archivable_type", null: false
    t.integer  "password_archivable_id",   null: false
    t.datetime "created_at"
  end

  add_index "old_passwords", ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree

  create_table "rpush_apps", force: :cascade do |t|
    t.string   "name",                                null: false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                null: false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
    t.integer  "application_id"
  end

  add_index "rpush_apps", ["application_id"], name: "index_rpush_apps_on_application_id", using: :btree

  create_table "rpush_feedback", force: :cascade do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id"
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: :cascade do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))", using: :btree

  create_table "triggers", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "event_type",     default: "enter"
    t.integer  "application_id"
    t.integer  "dwell_time"
    t.string   "type"
    t.integer  "activity_id"
    t.boolean  "test",           default: false
  end

  add_index "triggers", ["activity_id"], name: "index_triggers_on_activity_id", using: :btree
  add_index "triggers", ["application_id"], name: "index_triggers_on_application_id", using: :btree

  create_table "triggers_sources", force: :cascade do |t|
    t.integer "trigger_id",  null: false
    t.integer "source_id",   null: false
    t.string  "source_type", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string  "client_id",      null: false
    t.integer "application_id"
  end

  add_index "users", ["application_id", "client_id"], name: "index_users_on_application_id_and_client_id", using: :btree
  add_index "users", ["application_id"], name: "index_users_on_application_id", using: :btree

  create_table "zone_presence_stats", force: :cascade do |t|
    t.integer "zone_id",                 null: false
    t.date    "date",                    null: false
    t.integer "hour",                    null: false
    t.integer "users_count", default: 0
  end

  create_table "zones", force: :cascade do |t|
    t.string   "name",        null: false
    t.integer  "account_id",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
    t.integer  "manager_id"
    t.string   "color"
  end

  add_foreign_key "admins", "accounts"
  add_foreign_key "applications", "accounts"
  add_foreign_key "beacon_configs", "beacons"
  add_foreign_key "beacon_proximity_fields", "beacons"
  add_foreign_key "beacons", "accounts", name: "index_beacons_on_account_id"
  add_foreign_key "mobile_devices", "users"
  add_foreign_key "rpush_apps", "applications"
  add_foreign_key "users", "applications"
end
