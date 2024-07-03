# frozen_string_literal: true

require "test_helper"

class Blockchain::ArchiveBlockchainServiceTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"

    5.times do |i|
      ewc = create(:epoch_wall_clock, epoch: i, network: @network)
      slot = create(:testnet_slot, epoch: ewc.epoch, slot_number: i)
      block = create(:testnet_block, epoch: ewc.epoch, slot_number: i)
      create(:testnet_transaction, epoch: ewc.epoch, slot_number: i, block_id: block.id)
    end
  end

  test "#call archives blocks, slots and transactions only for a given epoch" do
    service = Blockchain::ArchiveBlockchainService.new(archive: true, network: @network, epoch: 1, processes: 1)
    service.call

    assert_equal 1, Blockchain::Block.network(@network).archived.count
    assert_equal 1, Blockchain::Slot.network(@network).archived.count
    assert_equal 1, Blockchain::Transaction.network(@network).archived.count
  end

end