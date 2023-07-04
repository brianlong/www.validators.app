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
#  epoch            :integer
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
#  validator_id     :integer
#
# Indexes
#
#  acceptable_stake_by_account_index                                (account,created_at,active_stake)
#  delinquent_by_account_index                                      (account,delinquent,created_at)
#  index_validator_histories_on_network_and_account_and_id          (network,account,id)
#  index_validator_histories_on_network_and_batch_uuid_and_account  (network,batch_uuid,account)
#  index_validator_histories_on_validator_id                        (validator_id)
#
class ValidatorHistory < ApplicationRecord
  # Use the monkey patch for median
  include PipelineLogic

  FIELDS_FOR_CSV = %i[
    epoch_credits
    epoch
  ].freeze

  API_FIELDS = %i[
    epoch_credits
    epoch
  ].freeze

  belongs_to :validator, optional: true

  scope :for_batch, ->(network, batch_uuid) { where(network: network, batch_uuid: batch_uuid) }
  scope :validator_histories_from_period, ->(network:, account:, from:, to:, limit:) do
    where(network: network, account: account, created_at: from...to)
      .order(created_at: :asc)
      .last(limit)
  end

  class << self
    
    def for_batch(network, batch_uuid)
      where(network: network, batch_uuid: batch_uuid)
    end

    def average_root_block_for(network, batch_uuid)
      for_batch(network, batch_uuid).batch.average(:root_block)
    end

    def highest_root_block_for(network, batch_uuid)
      for_batch(network, batch_uuid).maximum(:root_block)
    end

    def median_root_block_for(network, batch_uuid)
      for_batch(network, batch_uuid).median(:root_block)
    end

    def average_last_vote_for(network, batch_uuid)
      for_batch(network, batch_uuid).average(:last_vote)
    end

    def highest_last_vote_for(network, batch_uuid)
      for_batch(network, batch_uuid).maximum(:last_vote)
    end

    def median_last_vote_for(network, batch_uuid)
      for_batch(network, batch_uuid).median(:last_vote)
    end
  end

  def to_builder
    Jbuilder.new do |validator_history|
      validator_history.(
        self,
        *API_FIELDS
      )
    end
  end
end
