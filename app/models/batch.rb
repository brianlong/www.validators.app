# frozen_string_literal: true

# The Batch class will provide a UUID that we can use to keep track of all
# data retrieved in a batch.
# batch = Batch.create
# batch.uuid #=> A UUID

# == Schema Information
#
# Table name: batches
#
#  id          :bigint           not null, primary key
#  gathered_at :datetime
#  network     :string(255)
#  scored_at   :datetime
#  uuid        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_batches_on_network_and_created_at  (network,created_at)
#  index_batches_on_network_and_uuid        (network,uuid)
#
class Batch < ApplicationRecord
  before_create :create_uuid

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
