# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_24_223437) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "contact_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "username", null: false
    t.string "encrypted_password", default: "", null: false
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

  create_table "validator_block_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.integer "epoch"
    t.integer "leader_slots"
    t.integer "blocks_produced"
    t.integer "skipped_slots"
    t.decimal "skipped_slot_percent", precision: 10, scale: 4
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["validator_id", "created_at"], name: "index_validator_block_histories_on_validator_id_and_created_at"
    t.index ["validator_id", "epoch"], name: "index_validator_block_histories_on_validator_id_and_epoch"
    t.index ["validator_id"], name: "index_validator_block_histories_on_validator_id"
  end

  create_table "validator_ips", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.integer "version", default: 4
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["validator_id", "version", "address"], name: "index_validator_ips_on_validator_id_and_version_and_address", unique: true
    t.index ["validator_id"], name: "index_validator_ips_on_validator_id"
  end

  create_table "validators", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "network"
    t.string "account"
    t.string "name"
    t.string "keybase_id"
    t.string "www_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network", "account"], name: "index_validators_on_network_and_account", unique: true
  end

  create_table "vote_account_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "vote_account_id", null: false
    t.integer "commission"
    t.bigint "last_vote"
    t.bigint "root_slot"
    t.bigint "credits"
    t.bigint "activated_stake"
    t.string "software_version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["vote_account_id", "created_at"], name: "index_vote_account_histories_on_vote_account_id_and_created_at"
    t.index ["vote_account_id"], name: "index_vote_account_histories_on_vote_account_id"
  end

  create_table "vote_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "validator_id", null: false
    t.string "account"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account", "created_at"], name: "index_vote_accounts_on_account_and_created_at"
    t.index ["validator_id", "account"], name: "index_vote_accounts_on_validator_id_and_account", unique: true
    t.index ["validator_id"], name: "index_vote_accounts_on_validator_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "validator_block_histories", "validators"
  add_foreign_key "validator_ips", "validators"
  add_foreign_key "vote_account_histories", "vote_accounts"
  add_foreign_key "vote_accounts", "validators"
end
