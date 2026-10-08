# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_testnet_block_footers
#
#  id                        :bigint           not null, primary key
#  bank_hash                 :binary(32)
#  block_producer_time_nanos :bigint
#  block_user_agent          :string(191)
#  epoch                     :integer          not null
#  final_cert_slot           :bigint
#  final_notar_signers       :binary(2048)
#  final_signers             :binary(2048)
#  finalization              :integer
#  leader                    :string(191)
#  notar_reward_signers      :binary(2048)
#  notar_reward_slot         :bigint
#  processed                 :boolean          default(FALSE), not null
#  skip_reward_signers       :binary(2048)
#  skip_reward_slot          :bigint
#  slot_number               :bigint           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  bank_id                   :bigint
#
# Indexes
#
#  index_testnet_block_footers_on_created_at      (created_at)
#  index_testnet_block_footers_on_processed_slot  (processed,slot_number)
#  index_testnet_block_footers_on_slot_number     (slot_number) UNIQUE
#
class Blockchain::TestnetBlockFooter < Blockchain::BlockFooter
end
