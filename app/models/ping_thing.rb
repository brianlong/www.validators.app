# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_things
#
#  id                          :bigint           not null, primary key
#  amount                      :bigint
#  application                 :string(191)
#  commitment_level            :integer
#  network                     :string(191)
#  pinger_region               :string(191)
#  priority_fee_micro_lamports :float(24)
#  priority_fee_percentile     :integer
#  reported_at                 :datetime
#  response_time               :integer
#  signature                   :string(191)
#  slot_landed                 :bigint
#  slot_sent                   :bigint
#  success                     :boolean          default(TRUE)
#  transaction_type            :string(191)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  user_id                     :bigint           not null
#
# Indexes
#
#  index_ping_things_on_network                  (network)
#  index_ping_things_on_reported_at_and_network  (reported_at,network)
#  index_ping_things_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PingThing < ApplicationRecord

  include ObjectCopier
  extend Archivable

  API_FIELDS = %i[
    application
    commitment_level
    created_at
    network
    response_time
    signature
    success
    transaction_type
    slot_sent
    slot_landed
    reported_at
    pinger_region
    priority_fee_micro_lamports
    priority_fee_percentile
  ].freeze

  API_USER_FIELDS = %i[
    username
  ].freeze

  belongs_to :user

  enum commitment_level: { processed: 0, confirmed: 1, finalized: 2 }

  validates_presence_of :user_id, :response_time, :signature, :network
  validates_length_of :application, maximum: 80, allow_blank: true
  validates :network, inclusion: { in: NETWORKS }
  validates :signature, length: { in: 64..128 }

  scope :for_reported_at_range_and_network, -> (network, from, to) {
    where(network: network, reported_at: (from..to))
  }

  after_create :broadcast

  def to_builder
    Jbuilder.new do |ping_thing|
      ping_thing.(
        self,
        *API_FIELDS
      )
    end
  end

  def broadcast
    hash = {}
    hash.merge!(self.to_builder.attributes!)
    hash.merge!(self.user.to_builder.attributes!)

    ActionCable.server.broadcast("ping_thing_channel", hash)
  end

  def self.slot_latency_stats(records: nil)
    all = records || self.all
    latencies = all.map do |pt|
      next unless pt.slot_landed && pt.slot_sent
      pt.slot_landed.to_i >= pt.slot_sent.to_i ? pt.slot_landed - pt.slot_sent : nil
    end.compact.sort
    {
      min: latencies.min,
      median: latencies.median,
      p90: latencies.first((latencies.count * 0.9).round).last
    }
  end

  def self.time_stats(records: nil)
    all = records || self.all
    times = all.map(&:response_time).sort
    {
      min: times.min,
      median: times.median,
      p90: times.first((times.count * 0.9).round).last
    }
  end
end
