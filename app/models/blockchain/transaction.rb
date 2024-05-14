# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_transactions
#
#  id            :bigint           not null, primary key
#  account_key_1 :string(191)
#  account_key_2 :string(191)
#  account_key_3 :string(191)
#  fee           :bigint
#  post_balances :text(65535)
#  pre_balances  :text(65535)
#  slot_number   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  block_id      :bigint           not null
#
# Indexes
#
#  index_blockchain_transactions_on_block_id  (block_id)
#
# Foreign Keys
#
#  fk_rails_...  (block_id => blockchain_blocks.id)
#
class Blockchain::Transaction < ApplicationRecord
  serialize :pre_balances, JSON
  serialize :post_balances, JSON
end
