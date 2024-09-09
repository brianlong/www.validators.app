# frozen_string_literal: true

require "test_helper"

class Blockchain::ArchiveBlockchainServiceTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"

    5.times do |i|
      ewc = create(:epoch_wall_clock, epoch: i, network: @network)
      slot = create(:testnet_slot, epoch: ewc.epoch, slot_number: i)
      block = create(:testnet_block, epoch: ewc.epoch, slot_number: i)
      5.times do |j|
        create(:testnet_transaction, epoch: ewc.epoch, slot_number: i, block_id: block.id)
      end
    end
  end

end