# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_things
#
#  id               :bigint           not null, primary key
#  amount           :bigint
#  application      :string(191)
#  commitment_level :integer
#  network          :string(191)
#  reported_at      :datetime
#  response_time    :integer
#  signature        :string(191)
#  slot_landed      :bigint
#  slot_sent        :bigint
#  success          :boolean          default(TRUE)
#  transaction_type :string(191)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_ping_things_on_created_at_and_network_and_transaction_type  (created_at,network,transaction_type)
#  index_ping_things_on_created_at_and_network_and_user_id           (created_at,network,user_id)
#  index_ping_things_on_network                                      (network)
#  index_ping_things_on_reported_at_and_network                      (reported_at,network)
#  index_ping_things_on_user_id                                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PingThing < ApplicationRecord
  belongs_to :user
  include ObjectCopier

  enum commitment_level: { processed: 0, confirmed: 1, finalized: 2 }

  validates_presence_of :user_id, :response_time, :signature, :network
  validates_length_of :application, maximum: 80, allow_blank: true
  validates :network, inclusion: { in: NETWORKS }
  validates :signature, length: { in: 64..128 }

  scope :for_reported_at_range_and_network, -> (network, from, to) {
    where(network: network, reported_at: (from..to))
  }

  after_create :update_stats_if_present, :broadcast

  def to_builder
    Jbuilder.new do |ping_thing|
      ping_thing.(
        self,
        :application,
        :commitment_level,
        :created_at,
        :network,
        :response_time,
        :signature,
        :success,
        :transaction_type,
        :slot_sent,
        :slot_landed,
        :reported_at
      )
    end
  end

  def broadcast
    hash = {}
    hash.merge!(self.to_builder.attributes!)
    hash.merge!(self.user.to_builder.attributes!)

    ActionCable.server.broadcast("ping_thing_channel", hash)
  end

  def update_stats_if_present
    start = Time.now
    Rails.logger.warn("ProcessPingThing: update_stats_if_present (#{self.id}) start")
    Rails.logger.warn("ProcessPingThing: update_stats_if_present (#{self.id}) reported_at: #{reported_at}")

    stats = PingThingStat.by_network("mainnet").between_time_range(reported_at)
    Rails.logger.warn("ProcessPingThing: update_stats_if_present (#{self.id}) stats query time: #{Time.now - start}")
    
    stats_time = Time.now
    stats.each(&:recalculate)
    Rails.logger.warn("ProcessPingThing: update_stats_if_present time since stats (#{self.id}): #{Time.now - stats_time}s")
    Rails.logger.warn("ProcessPingThing: update_stats_if_present full method (#{self.id}): #{Time.now - start}s")
  end

  def self.average_slot_latency
    all.map{ |pt| pt.slot_landed && pt.slot_sent ? pt.slot_landed - pt.slot_sent : nil }.compact.average
  end
end
