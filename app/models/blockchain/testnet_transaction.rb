# == Schema Information
#
# Table name: blockchain_testnet_transactions
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
# Indexes
#
#  index_blockchain_testnet_transactions_on_block_id  (block_id)
#
# Foreign Keys
#
#  fk_rails_...  (block_id => blockchain_testnet_blocks.id)
#
class Blockchain::TestnetTransaction < Blockchain::Transaction
    belongs_to :block, class_name: 'Blockchain::TestnetBlock', foreign_key: 'block_id'
end
