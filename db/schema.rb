# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_09_093055) do

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "batches", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "uuid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network"
    t.datetime "gathered_at"
    t.datetime "scored_at"
    t.float "root_distance_all_average"
    t.integer "root_distance_all_median"
    t.float "vote_distance_all_average"
    t.integer "vote_distance_all_median"
    t.string "software_version"
    t.float "skipped_vote_all_median"
    t.float "best_skipped_vote"
    t.index ["network", "created_at"], name: "index_batches_on_network_and_created_at"
    t.index ["network", "scored_at"], name: "index_batches_on_network_and_scored_at"
    t.index ["network", "uuid"], name: "index_batches_on_network_and_uuid"
    t.index ["network"], name: "index_batches_on_network"
  end

  create_table "collectors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "payload_type"
    t.integer "payload_version"
    t.text "payload", size: :long
    t.string "ip_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_collectors_on_user_id"
  end

  create_table "commission_histories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.float "commission_before"
    t.float "commission_after"
    t.string "batch_uuid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network"
    t.integer "epoch"
    t.float "epoch_completion"
    t.index ["network", "validator_id"], name: "index_commission_histories_on_network_and_validator_id"
    t.index ["network"], name: "index_commission_histories_on_network"
    t.index ["validator_id"], name: "index_commission_histories_on_validator_id"
  end

  create_table "contact_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name_encrypted"
    t.string "email_address_encrypted"
    t.string "telephone_encrypted"
    t.text "comments_encrypted"
    t.string "name_encrypted_iv"
    t.string "email_address_encrypted_iv"
    t.string "telephone_encrypted_iv"
    t.string "comments_encrypted_iv"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "epoch_histories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "batch_uuid"
    t.integer "epoch"
    t.bigint "current_slot"
    t.integer "slot_index"
    t.integer "slots_in_epoch"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network"
    t.index ["network", "batch_uuid"], name: "index_epoch_histories_on_network_and_batch_uuid"
  end

  create_table "epoch_wall_clocks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "epoch"
    t.string "network"
    t.bigint "starting_slot"
    t.integer "slots_in_epoch"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "ending_slot"
    t.index ["network", "epoch"], name: "index_epoch_wall_clocks_on_network_and_epoch", unique: true
  end

  create_table "ip_overrides", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address"
    t.integer "traits_autonomous_system_number"
    t.string "country_iso_code"
    t.string "country_name"
    t.string "city_name"
    t.string "data_center_key"
    t.string "data_center_host"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "traits_autonomous_system_organization"
    t.index ["address"], name: "index_ip_overrides_on_address", unique: true
  end

  create_table "ips", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address"
    t.string "continent_code"
    t.integer "continent_geoname_id"
    t.string "continent_name"
    t.integer "country_confidence"
    t.string "country_iso_code"
    t.integer "country_geoname_id"
    t.string "country_name"
    t.string "registered_country_iso_code"
    t.integer "registered_country_geoname_id"
    t.string "registered_country_name"
    t.boolean "traits_anonymous"
    t.boolean "traits_hosting_provider"
    t.string "traits_user_type"
    t.integer "traits_autonomous_system_number"
    t.string "traits_autonomous_system_organization"
    t.string "traits_domain"
    t.string "traits_isp"
    t.string "traits_organization"
    t.string "traits_ip_address"
    t.string "traits_network"
    t.integer "city_confidence"
    t.integer "city_geoname_id"
    t.string "city_name"
    t.integer "location_average_income"
    t.integer "location_population_density"
    t.integer "location_accuracy_radius"
    t.decimal "location_latitude", precision: 9, scale: 6
    t.decimal "location_longitude", precision: 9, scale: 6
    t.integer "location_metro_code"
    t.string "location_time_zone"
    t.integer "postal_confidence"
    t.string "postal_code"
    t.integer "subdivision_confidence"
    t.string "subdivision_iso_code"
    t.integer "subdivision_geoname_id"
    t.integer "subdivision_name"
    t.string "data_center_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "data_center_host"
    t.index ["address"], name: "index_ips_on_address", unique: true
    t.index ["data_center_key"], name: "index_ips_on_data_center_key"
  end

  create_table "ping_time_stats", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "batch_uuid"
    t.decimal "overall_min_time", precision: 10, scale: 3
    t.decimal "overall_max_time", precision: 10, scale: 3
    t.decimal "overall_average_time", precision: 10, scale: 3
    t.datetime "observed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network"
    t.index ["network", "batch_uuid"], name: "index_ping_time_stats_on_network_and_batch_uuid"
  end

  create_table "ping_times", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "batch_uuid"
    t.string "network"
    t.string "from_account"
    t.string "from_ip"
    t.string "to_account"
    t.string "to_ip"
    t.decimal "min_ms", precision: 10, scale: 3
    t.decimal "avg_ms", precision: 10, scale: 3
    t.decimal "max_ms", precision: 10, scale: 3
    t.decimal "mdev", precision: 10, scale: 3
    t.datetime "observed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network", "batch_uuid"], name: "index_ping_times_on_network_and_batch_uuid"
    t.index ["network", "from_account", "created_at"], name: "index_ping_times_on_network_and_from_account_and_created_at"
    t.index ["network", "from_account", "to_account", "created_at"], name: "ndx_network_from_to_account"
    t.index ["network", "from_ip", "created_at"], name: "index_ping_times_on_network_and_from_ip_and_created_at"
    t.index ["network", "from_ip", "to_ip", "created_at"], name: "index_ping_times_on_network_and_from_ip_and_to_ip_and_created_at"
    t.index ["network", "to_account", "created_at"], name: "index_ping_times_on_network_and_to_account_and_created_at"
    t.index ["network", "to_account", "from_account", "created_at"], name: "ndx_network_to_from_account"
    t.index ["network", "to_ip", "created_at"], name: "index_ping_times_on_network_and_to_ip_and_created_at"
    t.index ["network", "to_ip", "from_ip", "created_at"], name: "index_ping_times_on_network_and_to_ip_and_from_ip_and_created_at"
  end

  create_table "reports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "network"
    t.string "name"
    t.text "payload", size: :long
    t.string "batch_uuid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network", "batch_uuid"], name: "index_reports_on_network_and_batch_uuid"
    t.index ["network", "name", "created_at"], name: "index_reports_on_network_and_name_and_created_at"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "username", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_admin", default: false
    t.string "email_encrypted"
    t.string "email_hash"
    t.string "api_token"
    t.string "email_encrypted_iv"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "validator_block_histories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.integer "epoch"
    t.integer "leader_slots"
    t.integer "blocks_produced"
    t.integer "skipped_slots"
    t.decimal "skipped_slot_percent", precision: 10, scale: 4
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "batch_uuid"
    t.integer "skipped_slots_after"
    t.decimal "skipped_slots_after_percent", precision: 10, scale: 4
    t.string "network"
    t.decimal "skipped_slot_percent_moving_average", precision: 10, scale: 4
    t.index ["network", "batch_uuid"], name: "index_validator_block_histories_on_network_and_batch_uuid"
    t.index ["validator_id", "created_at"], name: "index_validator_block_histories_on_validator_id_and_created_at"
    t.index ["validator_id", "epoch"], name: "index_validator_block_histories_on_validator_id_and_epoch"
    t.index ["validator_id"], name: "index_validator_block_histories_on_validator_id"
  end

  create_table "validator_block_history_stats", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "batch_uuid"
    t.integer "epoch", unsigned: true
    t.bigint "start_slot", unsigned: true
    t.bigint "end_slot", unsigned: true
    t.integer "total_slots", unsigned: true
    t.integer "total_blocks_produced", unsigned: true
    t.integer "total_slots_skipped", unsigned: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network"
    t.decimal "skipped_slot_percent_moving_average", precision: 10, scale: 4
    t.index ["network", "batch_uuid"], name: "index_validator_block_history_stats_on_network_and_batch_uuid"
  end

  create_table "validator_histories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "network"
    t.string "batch_uuid"
    t.string "account"
    t.string "vote_account"
    t.decimal "commission", precision: 10, unsigned: true
    t.bigint "last_vote", unsigned: true
    t.bigint "root_block", unsigned: true
    t.bigint "credits", unsigned: true
    t.bigint "active_stake", unsigned: true
    t.boolean "delinquent", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "software_version"
    t.index ["account", "created_at", "active_stake"], name: "acceptable_stake_by_account_index"
    t.index ["account", "delinquent", "created_at"], name: "delinquent_by_account_index"
    t.index ["network", "account", "id"], name: "index_validator_histories_on_network_and_account_and_id"
    t.index ["network", "batch_uuid"], name: "index_validator_histories_on_network_and_batch_uuid"
  end

  create_table "validator_ips", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.integer "version", default: 4
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["validator_id", "version", "address"], name: "index_validator_ips_on_validator_id_and_version_and_address", unique: true
    t.index ["validator_id"], name: "index_validator_ips_on_validator_id"
  end

  create_table "validator_score_v1s", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "validator_id"
    t.integer "total_score"
    t.text "root_distance_history"
    t.integer "root_distance_score"
    t.text "vote_distance_history"
    t.integer "vote_distance_score"
    t.text "skipped_slot_history"
    t.integer "skipped_slot_score"
    t.text "skipped_after_history"
    t.integer "skipped_after_score"
    t.string "software_version"
    t.integer "software_version_score"
    t.decimal "stake_concentration", precision: 10, scale: 3
    t.integer "stake_concentration_score"
    t.decimal "data_center_concentration", precision: 10, scale: 3
    t.integer "data_center_concentration_score"
    t.bigint "active_stake", unsigned: true
    t.integer "commission"
    t.decimal "ping_time_avg", precision: 10, scale: 3
    t.boolean "delinquent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "published_information_score"
    t.integer "security_report_score"
    t.string "ip_address"
    t.string "network"
    t.string "data_center_key"
    t.string "data_center_host"
    t.text "skipped_slot_moving_average_history"
    t.text "skipped_vote_history"
    t.text "skipped_vote_percent_moving_average_history"
    t.index ["network", "data_center_key"], name: "index_validator_score_v1s_on_network_and_data_center_key"
    t.index ["validator_id"], name: "index_validator_score_v1s_on_validator_id"
  end

  create_table "validators", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "network"
    t.string "account"
    t.string "name"
    t.string "keybase_id"
    t.string "www_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "details"
    t.string "info_pub_key"
    t.string "avatar_url"
    t.string "security_report_url"
    t.boolean "is_rpc", default: false
    t.boolean "is_active", default: true
    t.index ["network", "account"], name: "index_validators_on_network_and_account", unique: true
  end

  create_table "vote_account_histories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "vote_account_id", null: false
    t.integer "commission"
    t.bigint "last_vote"
    t.bigint "root_slot"
    t.bigint "credits"
    t.bigint "activated_stake"
    t.string "software_version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network"
    t.string "batch_uuid"
    t.bigint "credits_current"
    t.integer "slot_index_current"
    t.decimal "skipped_vote_percent_moving_average", precision: 10, scale: 4
    t.index ["network", "batch_uuid"], name: "index_vote_account_histories_on_network_and_batch_uuid"
    t.index ["vote_account_id", "created_at"], name: "index_vote_account_histories_on_vote_account_id_and_created_at"
    t.index ["vote_account_id"], name: "index_vote_account_histories_on_vote_account_id"
  end

  create_table "vote_accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.string "account"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network"
    t.index ["account", "created_at"], name: "index_vote_accounts_on_account_and_created_at"
    t.index ["network", "account"], name: "index_vote_accounts_on_network_and_account"
    t.index ["validator_id", "account"], name: "index_vote_accounts_on_validator_id_and_account", unique: true
    t.index ["validator_id"], name: "index_vote_accounts_on_validator_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collectors", "users"
  add_foreign_key "commission_histories", "validators"
  add_foreign_key "validator_block_histories", "validators"
  add_foreign_key "validator_ips", "validators"
  add_foreign_key "vote_account_histories", "vote_accounts"
  add_foreign_key "vote_accounts", "validators"
end
