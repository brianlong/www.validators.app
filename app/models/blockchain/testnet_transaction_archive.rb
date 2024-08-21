# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_testnet_transaction_archives
#
#  id            :bigint           not null, primary key
#  account_key_1 :string(191)
#  account_key_2 :string(191)
#  account_key_3 :string(191)
#  epoch         :integer
#  fee           :bigint
#  post_balances :text(65535)
#  pre_balances  :text(65535)
#  slot_number   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  block_id      :bigint
#
class Blockchain::TestnetTransactionArchive < ApplicationRecord
    connects_to database: { writing: :blockchain, reading: :blockchain }
    # connects_to database: { writing: Rails.env.stage? ? nil : :blockchain, reading: :blockchain }
end
