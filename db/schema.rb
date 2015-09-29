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

ActiveRecord::Schema.define(version: 20150929132753) do

  create_table "account_extensions", id: false, force: :cascade do |t|
    t.integer "account_id",     limit: 4
    t.string  "extension_name", limit: 255, null: false
  end

  add_index "account_extensions", ["account_id", "extension_name"], name: "index_account_extensions_on_account_id_and_extension_name", unique: true, using: :btree
  add_index "account_extensions", ["account_id"], name: "account_event_extensions_index", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "brand_id",   limit: 4,   null: false
  end

  create_table "activities", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "payload",    limit: 65535
    t.string   "scheme",     limit: 255
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "default_beacon_uuid",    limit: 255
    t.integer  "account_id",             limit: 4
    t.integer  "role",                   limit: 4,   default: 0
    t.string   "correlation_id",         limit: 255
    t.boolean  "walkthrough",            limit: 1,   default: false
  end

  add_index "admins", ["account_id"], name: "index_admins_on_account_id", using: :btree
  add_index "admins", ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true, using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "application_extensions", force: :cascade do |t|
    t.integer  "application_id", limit: 4
    t.text     "configuration",  limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "extension_name", limit: 255,   null: false
  end

  add_index "application_extensions", ["application_id", "extension_name"], name: "index_applications_extensions", unique: true, using: :btree
  add_index "application_extensions", ["application_id"], name: "index_application_extensions_on_application_id", using: :btree

  create_table "application_settings", force: :cascade do |t|
    t.integer  "application_id", limit: 4,     null: false
    t.string   "extension_name", limit: 255,   null: false
    t.string   "type",           limit: 255,   null: false
    t.string   "key",            limit: 255,   null: false
    t.text     "value",          limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "application_settings", ["application_id"], name: "index_application_settings_on_application_id", using: :btree

  create_table "applications", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "account_id", limit: 4
    t.boolean  "test",       limit: 1,   default: false
  end

  add_index "applications", ["account_id"], name: "index_applications_on_account_id", using: :btree

  create_table "applications_beacons", force: :cascade do |t|
    t.integer "application_id", limit: 4
    t.integer "beacon_id",      limit: 4
  end

  add_index "applications_beacons", ["application_id", "beacon_id"], name: "applications_beacons_index", using: :btree

  create_table "applications_zones", force: :cascade do |t|
    t.integer "application_id", limit: 4
    t.integer "zone_id",        limit: 4
  end

  add_index "applications_zones", ["application_id", "zone_id"], name: "applications_zones_index", using: :btree

  create_table "beacon_configs", force: :cascade do |t|
    t.integer  "beacon_id",         limit: 4
    t.string   "data",              limit: 255
    t.datetime "beacon_updated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "beacon_configs", ["beacon_id"], name: "index_beacon_configs_on_beacon_id", using: :btree

  create_table "beacon_presence_stats", force: :cascade do |t|
    t.string  "proximity_id", limit: 255,             null: false
    t.date    "date",                                 null: false
    t.integer "hour",         limit: 4,               null: false
    t.integer "users_count",  limit: 4,   default: 0
  end

  create_table "beacon_proximity_fields", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "value",      limit: 255
    t.integer  "beacon_id",  limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "beacon_proximity_fields", ["beacon_id"], name: "index_beacon_proximity_fields_on_beacon_id", using: :btree

  create_table "beacons", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "proximity_id", limit: 255
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.decimal  "lat",                      precision: 9, scale: 6
    t.decimal  "lng",                      precision: 9, scale: 6
    t.integer  "floor",        limit: 4
    t.integer  "account_id",   limit: 4
    t.integer  "zone_id",      limit: 4
    t.integer  "manager_id",   limit: 4
    t.string   "location",     limit: 255
    t.string   "protocol",     limit: 255,                         default: "iBeacon"
    t.string   "vendor",       limit: 255,                         default: "Other"
  end

  add_index "beacons", ["account_id"], name: "index_beacons_on_account_id", using: :btree
  add_index "beacons", ["proximity_id", "account_id"], name: "index_beacons_on_proximity_id_and_account_id", unique: true, using: :btree

  create_table "brands", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "coupon_images", force: :cascade do |t|
    t.integer  "coupon_id",  limit: 4
    t.string   "file",       limit: 255
    t.string   "type",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "coupon_images", ["coupon_id"], name: "index_coupon_images_on_coupon_id", using: :btree

  create_table "coupons", force: :cascade do |t|
    t.string   "template",                 limit: 255
    t.string   "name",                     limit: 255
    t.string   "title",                    limit: 255
    t.text     "description",              limit: 65535
    t.integer  "activity_id",              limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "identifier_number",        limit: 255
    t.string   "unique_identifier_number", limit: 255
    t.integer  "encoding_type",            limit: 4
    t.string   "button_font_color",        limit: 255
    t.string   "button_background_color",  limit: 255
    t.string   "button_label",             limit: 255
    t.string   "button_link",              limit: 255
  end

  add_index "coupons", ["activity_id"], name: "index_coupons_on_activity_id", using: :btree
  add_index "coupons", ["template"], name: "index_coupons_on_template", using: :btree

  create_table "custom_attributes", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "value",       limit: 255
    t.integer  "activity_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "custom_attributes", ["activity_id"], name: "index_custom_attributes_on_activity_id", using: :btree

  create_table "ext_analytics_beacons_dwell_time_aggregations", force: :cascade do |t|
    t.integer "ext_analytics_dwell_time_aggregation_id", limit: 4, null: false
    t.integer "beacon_id",                               limit: 4, null: false
  end

  add_index "ext_analytics_beacons_dwell_time_aggregations", ["ext_analytics_dwell_time_aggregation_id", "beacon_id"], name: "ext_analytics_dta_beacon_idx", using: :btree

  create_table "ext_analytics_beacons_events", id: false, force: :cascade do |t|
    t.integer "ext_analytics_event_id", limit: 4, null: false
    t.integer "beacon_id",              limit: 4, null: false
  end

  add_index "ext_analytics_beacons_events", ["ext_analytics_event_id", "beacon_id"], name: "ext_analytics_beacons_events_idx", using: :btree

  create_table "ext_analytics_beacons_zones", id: false, force: :cascade do |t|
    t.integer "ext_analytics_event_id", limit: 4, null: false
    t.integer "zone_id",                limit: 4, null: false
  end

  add_index "ext_analytics_beacons_zones", ["ext_analytics_event_id", "zone_id"], name: "ext_analytics_beacons_zones_idx", using: :btree

  create_table "ext_analytics_dwell_time_aggregations", force: :cascade do |t|
    t.integer  "application_id", limit: 4,               null: false
    t.string   "proximity_id",   limit: 255,             null: false
    t.string   "user_id",        limit: 255
    t.date     "date",                                   null: false
    t.datetime "timestamp",                              null: false
    t.integer  "dwell_time",     limit: 4,   default: 0, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "ext_analytics_dwell_time_aggregations", ["application_id"], name: "index_ext_analytics_dwell_time_aggregations_on_application_id", using: :btree
  add_index "ext_analytics_dwell_time_aggregations", ["date"], name: "index_ext_analytics_dwell_time_aggregations_on_date", using: :btree
  add_index "ext_analytics_dwell_time_aggregations", ["proximity_id"], name: "index_ext_analytics_dwell_time_aggregations_on_proximity_id", using: :btree
  add_index "ext_analytics_dwell_time_aggregations", ["timestamp"], name: "index_ext_analytics_dwell_time_aggregations_on_timestamp", using: :btree
  add_index "ext_analytics_dwell_time_aggregations", ["user_id"], name: "index_ext_analytics_dwell_time_aggregations_on_user_id", using: :btree

  create_table "ext_analytics_dwell_time_aggregations_zones", force: :cascade do |t|
    t.integer "ext_analytics_dwell_time_aggregation_id", limit: 4, null: false
    t.integer "zone_id",                                 limit: 4, null: false
  end

  add_index "ext_analytics_dwell_time_aggregations_zones", ["ext_analytics_dwell_time_aggregation_id", "zone_id"], name: "ext_analytics_dta_zone_idx", using: :btree

  create_table "ext_analytics_events", force: :cascade do |t|
    t.integer  "application_id", limit: 4,   null: false
    t.string   "proximity_id",   limit: 255, null: false
    t.string   "user_id",        limit: 255
    t.string   "event_type",     limit: 255, null: false
    t.integer  "action_id",      limit: 4
    t.datetime "timestamp",                  null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "ext_analytics_events", ["application_id"], name: "index_ext_analytics_events_on_application_id", using: :btree
  add_index "ext_analytics_events", ["event_type"], name: "index_ext_analytics_events_on_event_type", using: :btree
  add_index "ext_analytics_events", ["proximity_id"], name: "index_ext_analytics_events_on_proximity_id", using: :btree
  add_index "ext_analytics_events", ["timestamp"], name: "index_ext_analytics_events_on_timestamp", using: :btree
  add_index "ext_analytics_events", ["user_id"], name: "index_ext_analytics_events_on_user_id", using: :btree

  create_table "ext_kontakt_io_beacon_assignments", force: :cascade do |t|
    t.integer "beacon_id", limit: 4,   null: false
    t.string  "unique_id", limit: 255, null: false
  end

  add_index "ext_kontakt_io_beacon_assignments", ["beacon_id"], name: "index_ext_kontakt_io_beacon_assignments_on_beacon_id", using: :btree

  create_table "ext_kontakt_io_mapping", force: :cascade do |t|
    t.string  "target_type", limit: 255
    t.integer "target_id",   limit: 4
    t.string  "kontakt_uid", limit: 255
  end

  create_table "ext_neighbours_zone_neighbours", force: :cascade do |t|
    t.integer  "source_id",  limit: 4
    t.integer  "target_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ext_presence_beacon_presences", force: :cascade do |t|
    t.integer  "beacon_id",  limit: 4
    t.string   "client_id",  limit: 255
    t.datetime "timestamp"
    t.boolean  "present",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "ext_presence_zone_presences", force: :cascade do |t|
    t.integer  "zone_id",    limit: 4
    t.string   "client_id",  limit: 255
    t.datetime "timestamp"
    t.boolean  "present",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "extension_settings", force: :cascade do |t|
    t.integer "account_id",     limit: 4,   null: false
    t.string  "extension_name", limit: 255, null: false
    t.string  "key",            limit: 255, null: false
    t.string  "value",          limit: 255
  end

  create_table "mobile_devices", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.text     "push_token",      limit: 65535
    t.integer  "os",              limit: 4,                    null: false
    t.integer  "environment",     limit: 4,     default: 1,    null: false
    t.boolean  "active",          limit: 1,     default: true, null: false
    t.datetime "last_sign_in_at"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "correlation_id",  limit: 255
  end

  add_index "mobile_devices", ["active"], name: "index_mobile_devices_on_active", using: :btree
  add_index "mobile_devices", ["user_id"], name: "index_mobile_devices_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 255,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4
    t.integer  "application_id",    limit: 4
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in",        limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                null: false
    t.string   "uid",          limit: 255,                null: false
    t.string   "secret",       limit: 255,                null: false
    t.text     "redirect_uri", limit: 65535,              null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "owner_id",     limit: 4
    t.string   "owner_type",   limit: 255
    t.string   "scopes",       limit: 255,   default: "", null: false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       limit: 255, null: false
    t.string   "password_salt",            limit: 255
    t.string   "password_archivable_type", limit: 255, null: false
    t.integer  "password_archivable_id",   limit: 4,   null: false
    t.datetime "created_at"
  end

  add_index "old_passwords", ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree

  create_table "rpush_apps", force: :cascade do |t|
    t.string   "name",                    limit: 255,               null: false
    t.string   "environment",             limit: 255
    t.text     "certificate",             limit: 65535
    t.string   "password",                limit: 255
    t.integer  "connections",             limit: 4,     default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                    limit: 255,               null: false
    t.string   "auth_key",                limit: 255
    t.string   "client_id",               limit: 255
    t.string   "client_secret",           limit: 255
    t.string   "access_token",            limit: 255
    t.datetime "access_token_expiration"
    t.integer  "application_id",          limit: 4
  end

  add_index "rpush_apps", ["application_id"], name: "index_rpush_apps_on_application_id", using: :btree

  create_table "rpush_feedback", force: :cascade do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id",       limit: 4
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer  "badge",             limit: 4
    t.string   "device_token",      limit: 64
    t.string   "sound",             limit: 255,      default: "default"
    t.string   "alert",             limit: 255
    t.text     "data",              limit: 65535
    t.integer  "expiry",            limit: 4,        default: 86400
    t.boolean  "delivered",         limit: 1,        default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",            limit: 1,        default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code",        limit: 4
    t.text     "error_description", limit: 65535
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alert_is_json",     limit: 1,        default: false
    t.string   "type",              limit: 255,                          null: false
    t.string   "collapse_key",      limit: 255
    t.boolean  "delay_while_idle",  limit: 1,        default: false,     null: false
    t.text     "registration_ids",  limit: 16777215
    t.integer  "app_id",            limit: 4,                            null: false
    t.integer  "retries",           limit: 4,        default: 0
    t.string   "uri",               limit: 255
    t.datetime "fail_after"
    t.boolean  "processing",        limit: 1,        default: false,     null: false
    t.integer  "priority",          limit: 4
    t.text     "url_args",          limit: 65535
    t.string   "category",          limit: 255
  end

  add_index "rpush_notifications", ["app_id", "delivered", "failed", "deliver_after"], name: "index_rapns_notifications_multi", using: :btree
  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", using: :btree

  create_table "triggers", force: :cascade do |t|
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "event_type",     limit: 255, default: "enter"
    t.integer  "application_id", limit: 4
    t.string   "type",           limit: 255
    t.integer  "activity_id",    limit: 4
    t.boolean  "test",           limit: 1,   default: false
    t.integer  "dwell_time",     limit: 4
  end

  add_index "triggers", ["activity_id"], name: "index_triggers_on_activity_id", using: :btree
  add_index "triggers", ["application_id"], name: "index_triggers_on_application_id", using: :btree

  create_table "triggers_sources", force: :cascade do |t|
    t.integer "trigger_id",  limit: 4,   null: false
    t.integer "source_id",   limit: 4,   null: false
    t.string  "source_type", limit: 255, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string  "client_id",      limit: 255, null: false
    t.integer "application_id", limit: 4
  end

  add_index "users", ["application_id", "client_id"], name: "index_users_on_application_id_and_client_id", using: :btree
  add_index "users", ["application_id"], name: "index_users_on_application_id", using: :btree

  create_table "zone_presence_stats", force: :cascade do |t|
    t.integer "zone_id",     limit: 4,             null: false
    t.date    "date",                              null: false
    t.integer "hour",        limit: 4,             null: false
    t.integer "users_count", limit: 4, default: 0
  end

  create_table "zones", force: :cascade do |t|
    t.string   "name",          limit: 255,               null: false
    t.integer  "account_id",    limit: 4,                 null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "description",   limit: 65535
    t.integer  "manager_id",    limit: 4
    t.string   "color",         limit: 255
    t.integer  "beacons_count", limit: 4,     default: 0
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
