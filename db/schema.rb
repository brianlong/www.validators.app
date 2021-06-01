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

ActiveRecord::Schema.define(version: 2021_05_14_111517) do

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "record_type", limit: 255, null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", limit: 255, null: false
    t.string "filename", limit: 255, null: false
    t.string "content_type", limit: 255
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", limit: 255, null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "audits", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "auditable_id", unsigned: true
    t.string "auditable_type", limit: 255
    t.bigint "associated_id", unsigned: true
    t.string "associated_type", limit: 255
    t.bigint "user_id", unsigned: true
    t.string "user_type", limit: 255
    t.string "username", limit: 255
    t.string "action", limit: 255
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment", limit: 255
    t.string "remote_address", limit: 255
    t.string "request_uuid", limit: 255
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "batches", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network", limit: 255
    t.datetime "gathered_at"
    t.datetime "scored_at"
    t.float "root_distance_all_average"
    t.integer "root_distance_all_median"
    t.float "vote_distance_all_average"
    t.integer "vote_distance_all_median"
    t.string "software_version"
    t.index ["network", "created_at"], name: "index_batches_on_network_and_created_at"
    t.index ["network", "scored_at"], name: "index_batches_on_network_and_scored_at"
    t.index ["network", "uuid"], name: "index_batches_on_network_and_uuid"
  end

  create_table "block_commitments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "network", limit: 255
    t.bigint "slot"
    t.text "commitment"
    t.bigint "total_stake"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network", "slot"], name: "index_block_commitments_on_network_and_slot", unique: true
  end

  create_table "collectors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "payload_type", limit: 255
    t.integer "payload_version"
    t.text "payload", size: :long
    t.string "ip_address", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_collectors_on_user_id"
  end

  create_table "contact_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name_encrypted", limit: 255
    t.string "email_address_encrypted", limit: 255
    t.string "telephone_encrypted", limit: 255
    t.text "comments_encrypted"
    t.string "name_encrypted_iv", limit: 255
    t.string "email_address_encrypted_iv", limit: 255
    t.string "telephone_encrypted_iv", limit: 255
    t.string "comments_encrypted_iv", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "epoch_histories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "batch_uuid", limit: 255
    t.integer "epoch"
    t.bigint "current_slot"
    t.integer "slot_index"
    t.integer "slots_in_epoch"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network", limit: 255
    t.index ["network", "batch_uuid"], name: "index_epoch_histories_on_network_and_batch_uuid"
  end

  create_table "epoch_wall_clocks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "epoch"
    t.string "network"
    t.bigint "starting_slot"
    t.integer "slots_in_epoch"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "ending_slot"
    t.index ["network", "epoch"], name: "index_epoch_wall_clocks_on_network_and_epoch", unique: true
  end

  create_table "ip_overrides", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address", limit: 255
    t.integer "traits_autonomous_system_number"
    t.string "country_iso_code", limit: 255
    t.string "country_name", limit: 255
    t.string "city_name", limit: 255
    t.string "data_center_key", limit: 255
    t.string "data_center_host", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "traits_autonomous_system_organization", limit: 255
    t.index ["address"], name: "index_ip_overrides_on_address", unique: true
  end

  create_table "ips", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address", limit: 255
    t.string "continent_code", limit: 255
    t.integer "continent_geoname_id"
    t.string "continent_name", limit: 255
    t.integer "country_confidence"
    t.string "country_iso_code", limit: 255
    t.integer "country_geoname_id"
    t.string "country_name", limit: 255
    t.string "registered_country_iso_code", limit: 255
    t.integer "registered_country_geoname_id"
    t.string "registered_country_name", limit: 255
    t.boolean "traits_anonymous"
    t.boolean "traits_hosting_provider"
    t.string "traits_user_type", limit: 255
    t.integer "traits_autonomous_system_number"
    t.string "traits_autonomous_system_organization", limit: 255
    t.string "traits_domain", limit: 255
    t.string "traits_isp", limit: 255
    t.string "traits_organization", limit: 255
    t.string "traits_ip_address", limit: 255
    t.string "traits_network", limit: 255
    t.integer "city_confidence"
    t.integer "city_geoname_id"
    t.string "city_name", limit: 255
    t.integer "location_average_income"
    t.integer "location_population_density"
    t.integer "location_accuracy_radius"
    t.decimal "location_latitude", precision: 9, scale: 6
    t.decimal "location_longitude", precision: 9, scale: 6
    t.integer "location_metro_code"
    t.string "location_time_zone", limit: 255
    t.integer "postal_confidence"
    t.string "postal_code", limit: 255
    t.integer "subdivision_confidence"
    t.string "subdivision_iso_code", limit: 255
    t.integer "subdivision_geoname_id"
    t.integer "subdivision_name"
    t.string "data_center_key", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "data_center_host", limit: 255
    t.index ["address"], name: "index_ips_on_address", unique: true
    t.index ["data_center_key"], name: "index_ips_on_data_center_key"
  end

  create_table "ping_time_stats", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "batch_uuid", limit: 255
    t.decimal "overall_min_time", precision: 10, scale: 3
    t.decimal "overall_max_time", precision: 10, scale: 3
    t.decimal "overall_average_time", precision: 10, scale: 3
    t.datetime "observed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network", limit: 255
    t.index ["network", "batch_uuid"], name: "index_ping_time_stats_on_network_and_batch_uuid"
  end

  create_table "ping_times", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "batch_uuid", limit: 255
    t.string "network", limit: 255
    t.string "from_account", limit: 255
    t.string "from_ip", limit: 255
    t.string "to_account", limit: 255
    t.string "to_ip", limit: 255
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

  create_table "reports", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "network", limit: 255
    t.string "name", limit: 255
    t.text "payload", size: :long
    t.string "batch_uuid", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network", "batch_uuid"], name: "index_reports_on_network_and_batch_uuid"
    t.index ["network", "name", "created_at"], name: "index_reports_on_network_and_name_and_created_at"
  end

  create_table "slots", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "network", limit: 255
    t.bigint "slot_number"
    t.string "leader_account", limit: 255
    t.boolean "skipped"
    t.bigint "block_unix_time"
    t.datetime "block_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network", "slot_number"], name: "index_slots_on_network_and_slot_number", unique: true
  end

  create_table "stake_boss_stake_accounts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", unsigned: true
    t.string "batch_uuid", limit: 255
    t.string "network", limit: 255
    t.string "address", limit: 255
    t.bigint "account_balance", unsigned: true
    t.bigint "activating_stake", unsigned: true
    t.integer "activation_epoch"
    t.bigint "active_stake", unsigned: true
    t.bigint "credits_observed", unsigned: true
    t.integer "deactivation_epoch"
    t.bigint "delegated_stake", unsigned: true
    t.string "delegated_vote_account_address", limit: 255
    t.integer "epoch"
    t.bigint "epoch_rewards", unsigned: true
    t.string "lockup_custodian", limit: 255
    t.bigint "lockup_timestamp", unsigned: true
    t.bigint "rent_exempt_reserve", unsigned: true
    t.string "stake_authority", limit: 255
    t.string "stake_type", limit: 255
    t.string "withdraw_authority", limit: 255
    t.integer "split_n_ways"
    t.boolean "primary_account", default: false
    t.datetime "split_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["batch_uuid", "primary_account"], name: "stake_boss_stake_accounts_batch_uuid_primary_account"
    t.index ["network", "address"], name: "stake_boss_stake_accounts_network_address", unique: true
    t.index ["user_id"], name: "stake_boss_stake_accounts_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "username", limit: 255, null: false
    t.string "encrypted_password", limit: 255, null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email", limit: 255
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token", limit: 255
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_admin", default: false
    t.string "email_encrypted", limit: 255
    t.string "email_hash", limit: 255
    t.string "api_token", limit: 255
    t.string "email_encrypted_iv", limit: 255
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "validator_block_histories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.integer "epoch"
    t.integer "leader_slots"
    t.integer "blocks_produced"
    t.integer "skipped_slots"
    t.decimal "skipped_slot_percent", precision: 10, scale: 4
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "batch_uuid", limit: 255
    t.integer "skipped_slots_after"
    t.decimal "skipped_slots_after_percent", precision: 10, scale: 4
    t.string "network", limit: 255
    t.decimal "skipped_slot_percent_moving_average", precision: 10, scale: 4
    t.index ["network", "batch_uuid"], name: "index_validator_block_histories_on_network_and_batch_uuid"
    t.index ["validator_id", "created_at"], name: "index_validator_block_histories_on_validator_id_and_created_at"
    t.index ["validator_id", "epoch"], name: "index_validator_block_histories_on_validator_id_and_epoch"
    t.index ["validator_id"], name: "index_validator_block_histories_on_validator_id"
  end

  create_table "validator_block_history_stats", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "batch_uuid", limit: 255
    t.integer "epoch", unsigned: true
    t.bigint "start_slot", unsigned: true
    t.bigint "end_slot", unsigned: true
    t.integer "total_slots", unsigned: true
    t.integer "total_blocks_produced", unsigned: true
    t.integer "total_slots_skipped", unsigned: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network", limit: 255
    t.decimal "skipped_slot_percent_moving_average", precision: 10, scale: 4
    t.index ["network", "batch_uuid"], name: "index_validator_block_history_stats_on_network_and_batch_uuid"
  end

  create_table "validator_histories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "network", limit: 255
    t.string "batch_uuid", limit: 255
    t.string "account", limit: 255
    t.string "vote_account", limit: 255
    t.decimal "commission", precision: 10, unsigned: true
    t.bigint "last_vote", unsigned: true
    t.bigint "root_block", unsigned: true
    t.bigint "credits", unsigned: true
    t.bigint "active_stake", unsigned: true
    t.boolean "delinquent", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "software_version", limit: 255
    t.index ["network", "account", "id"], name: "index_validator_histories_on_network_and_account_and_id"
    t.index ["network", "batch_uuid"], name: "index_validator_histories_on_network_and_batch_uuid"
  end

  create_table "validator_ips", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.integer "version", default: 4
    t.string "address", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["validator_id", "version", "address"], name: "index_validator_ips_on_validator_id_and_version_and_address", unique: true
    t.index ["validator_id"], name: "index_validator_ips_on_validator_id"
  end

  create_table "validator_score_v1s", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
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
    t.string "software_version", limit: 255
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
    t.string "ip_address", limit: 255
    t.string "network", limit: 255
    t.string "data_center_key", limit: 255
    t.string "data_center_host", limit: 255
    t.text "skipped_slot_moving_average_history"
    t.text "skipped_vote_history"
    t.text "skipped_vote_percent_moving_average_history"
    t.index ["network", "data_center_key"], name: "index_validator_score_v1s_on_network_and_data_center_key"
    t.index ["validator_id"], name: "index_validator_score_v1s_on_validator_id"
  end

  create_table "validators", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "network", limit: 255
    t.string "account", limit: 255
    t.string "name", limit: 255
    t.string "keybase_id", limit: 255
    t.string "www_url", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "details", limit: 255
    t.string "info_pub_key", limit: 255
    t.string "avatar_url", limit: 255
    t.string "security_report_url", limit: 255
    t.index ["network", "account"], name: "index_validators_on_network_and_account", unique: true
  end

  create_table "vote_account_histories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "vote_account_id", null: false
    t.integer "commission"
    t.bigint "last_vote"
    t.bigint "root_slot"
    t.bigint "credits"
    t.bigint "activated_stake"
    t.string "software_version", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network", limit: 255
    t.string "batch_uuid", limit: 255
    t.bigint "credits_current"
    t.integer "slot_index_current"
    t.decimal "skipped_vote_percent_moving_average", precision: 10, scale: 4
    t.index ["network", "batch_uuid"], name: "index_vote_account_histories_on_network_and_batch_uuid"
    t.index ["vote_account_id", "created_at"], name: "index_vote_account_histories_on_vote_account_id_and_created_at"
    t.index ["vote_account_id"], name: "index_vote_account_histories_on_vote_account_id"
  end

  create_table "vote_accounts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.string "account", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "network", limit: 255
    t.index ["account", "created_at"], name: "index_vote_accounts_on_account_and_created_at"
    t.index ["network", "account"], name: "index_vote_accounts_on_network_and_account"
    t.index ["validator_id", "account"], name: "index_vote_accounts_on_validator_id_and_account", unique: true
    t.index ["validator_id"], name: "index_vote_accounts_on_validator_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collectors", "users"
  add_foreign_key "validator_block_histories", "validators"
  add_foreign_key "validator_ips", "validators"
  add_foreign_key "vote_account_histories", "vote_accounts"
  add_foreign_key "vote_accounts", "validators"
end
