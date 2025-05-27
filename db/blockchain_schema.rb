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

ActiveRecord::Schema.define(version: 2025_03_19_115610) do

  create_table "blockchain_mainnet_block_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "blockhash"
    t.integer "epoch"
    t.integer "height"
    t.bigint "parent_slot"
    t.bigint "block_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "processed", default: false
  end

  create_table "blockchain_mainnet_blocks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "blockhash"
    t.integer "epoch"
    t.integer "height"
    t.bigint "parent_slot"
    t.bigint "block_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "processed", default: false
    t.index ["blockhash"], name: "index_blockchain_mainnet_blocks_on_blockhash"
    t.index ["created_at", "processed"], name: "index_blockchain_mainnet_blocks_on_created_at_and_processed"
    t.index ["slot_number"], name: "index_blockchain_mainnet_blocks_on_slot_number"
  end

  create_table "blockchain_mainnet_slot_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "leader"
    t.integer "epoch"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "blockchain_mainnet_slots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "leader"
    t.integer "epoch"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["epoch", "leader"], name: "index_blockchain_mainnet_slots_on_epoch_and_leader"
  end

  create_table "blockchain_mainnet_transaction_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.bigint "fee"
    t.text "pre_balances"
    t.text "post_balances"
    t.string "account_key_1"
    t.string "account_key_2"
    t.string "account_key_3"
    t.integer "epoch"
    t.bigint "block_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "recent_blockhash"
  end

  create_table "blockchain_mainnet_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.bigint "fee"
    t.text "pre_balances"
    t.text "post_balances"
    t.string "account_key_1"
    t.string "account_key_2"
    t.string "account_key_3"
    t.integer "epoch"
    t.bigint "block_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "recent_blockhash"
    t.index ["block_id"], name: "index_blockchain_mainnet_transactions_on_block_id"
  end

  create_table "blockchain_pythnet_block_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "blockhash"
    t.integer "epoch"
    t.integer "height"
    t.bigint "parent_slot"
    t.bigint "block_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "processed", default: false
  end

  create_table "blockchain_pythnet_blocks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "blockhash"
    t.integer "epoch"
    t.integer "height"
    t.bigint "parent_slot"
    t.bigint "block_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "processed", default: false
    t.index ["blockhash"], name: "index_blockchain_pythnet_blocks_on_blockhash"
    t.index ["created_at", "processed"], name: "index_blockchain_pythnet_blocks_on_created_at_and_processed"
    t.index ["slot_number"], name: "index_blockchain_pythnet_blocks_on_slot_number"
  end

  create_table "blockchain_pythnet_slot_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "leader"
    t.integer "epoch"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "blockchain_pythnet_slots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "leader"
    t.integer "epoch"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["epoch", "leader"], name: "index_blockchain_pythnet_slots_on_epoch_and_leader"
  end

  create_table "blockchain_pythnet_transaction_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.bigint "fee"
    t.text "pre_balances"
    t.text "post_balances"
    t.string "account_key_1"
    t.string "account_key_2"
    t.string "account_key_3"
    t.integer "epoch"
    t.bigint "block_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "recent_blockhash"
  end

  create_table "blockchain_pythnet_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.bigint "fee"
    t.text "pre_balances"
    t.text "post_balances"
    t.string "account_key_1"
    t.string "account_key_2"
    t.string "account_key_3"
    t.integer "epoch"
    t.bigint "block_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "recent_blockhash"
    t.index ["block_id"], name: "index_blockchain_pythnet_transactions_on_block_id"
  end

  create_table "blockchain_testnet_block_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "blockhash"
    t.integer "epoch"
    t.integer "height"
    t.bigint "parent_slot"
    t.bigint "block_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "processed", default: false
  end

  create_table "blockchain_testnet_blocks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "blockhash"
    t.integer "epoch"
    t.integer "height"
    t.bigint "parent_slot"
    t.bigint "block_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "processed", default: false
    t.index ["blockhash"], name: "index_blockchain_testnet_blocks_on_blockhash"
    t.index ["created_at", "processed"], name: "index_blockchain_testnet_blocks_on_created_at_and_processed"
    t.index ["slot_number"], name: "index_blockchain_testnet_blocks_on_slot_number"
  end

  create_table "blockchain_testnet_slot_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "leader"
    t.integer "epoch"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "blockchain_testnet_slots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.string "leader"
    t.integer "epoch"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["epoch", "leader"], name: "index_blockchain_testnet_slots_on_epoch_and_leader"
  end

  create_table "blockchain_testnet_transaction_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.bigint "fee"
    t.text "pre_balances"
    t.text "post_balances"
    t.string "account_key_1"
    t.string "account_key_2"
    t.string "account_key_3"
    t.integer "epoch"
    t.bigint "block_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "recent_blockhash"
  end

  create_table "blockchain_testnet_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slot_number"
    t.bigint "fee"
    t.text "pre_balances"
    t.text "post_balances"
    t.string "account_key_1"
    t.string "account_key_2"
    t.string "account_key_3"
    t.integer "epoch"
    t.bigint "block_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "recent_blockhash"
    t.index ["block_id"], name: "index_blockchain_testnet_transactions_on_block_id"
  end

end
