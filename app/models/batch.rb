# frozen_string_literal: true

# The Batch class will provide a UUID that we can use to keep track of all
# data retrieved in a batch.
# batch = Batch.create
# batch.uuid #=> A UUID

# == Schema Information
#
# Table name: batches
#
#  id                        :bigint           not null, primary key
#  best_skipped_vote         :float(24)
#  gathered_at               :datetime
#  network                   :string(191)
#  other_software_versions   :text(65535)
#  root_distance_all_average :float(24)
#  root_distance_all_median  :integer
#  scored_at                 :datetime
#  skipped_after_all_average :float(24)        default(0.0)
#  skipped_slot_all_average  :float(24)        default(0.0)
#  skipped_vote_all_median   :float(24)
#  software_version          :string(191)
#  uuid                      :string(191)
#  vote_distance_all_average :float(24)
#  vote_distance_all_median  :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_batches_on_network_and_created_at  (network,created_at)
#  index_batches_on_network_and_scored_at   (network,scored_at)
#  index_batches_on_network_and_uuid        (network,uuid)
#
class Batch < ApplicationRecord
  before_create :create_uuid

  serialize :other_software_versions, JSON

  def self.last_scored(network)
    where('network = ? and scored_at IS NOT NULL', network).last
  end

  protected

  # Internal method assigns a UUID to a Host object's uuid attribute. This
  # method is called by the before_create method.
  #
  # SecureRandom.uuid generates a v4 random UUID (Universally Unique IDentifier)
  #
  # Returns nothing.
  def create_uuid
    self.uuid = SecureRandom.uuid
  end
end
