# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_histories
#
#  id               :bigint           not null, primary key
#  account          :string(191)
#  active_stake     :bigint           unsigned
#  batch_uuid       :string(191)
#  commission       :decimal(10, )    unsigned
#  credits          :bigint           unsigned
#  delinquent       :boolean          default(FALSE)
#  epoch_credits    :integer          unsigned
#  last_vote        :bigint           unsigned
#  max_root_height  :bigint           unsigned
#  max_vote_height  :bigint           unsigned
#  network          :string(191)
#  root_block       :bigint           unsigned
#  root_distance    :bigint           unsigned
#  slot_skip_rate   :float(24)        unsigned
#  software_version :string(191)
#  vote_account     :string(191)
#  vote_distance    :bigint           unsigned
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  acceptable_stake_by_account_index                        (account,created_at,active_stake)
#  delinquent_by_account_index                              (account,delinquent,created_at)
#  index_validator_histories_on_network_and_account_and_id  (network,account,id)
#  index_validator_histories_on_network_and_batch_uuid      (network,batch_uuid)
#
class ValidatorHistory < ApplicationRecord
  # Use the monkey patch for median
  include PipelineLogic

  def validator
    Validator.find_by(network: network, account: account)
  end
end
