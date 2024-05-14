# frozen_string_literal: true

require 'test_helper'

class ArchiveBlockchainTest < ActiveSupport::TestCase
  test 'archives blockchain data' do
    create(:epoch_wall_clock, epoch: 342, network: "testnet")

    slot = create(:blockchain_slot, epoch: 335, network: "testnet")
    block = create(:blockchain_block, slot_number: slot.slot_number)
    create(:blockchain_transaction, slot_number: slot.slot_number, block_id: block.id)

    load(Rails.root.join('script', 'archives', 'archive_blockchain.rb'))

    assert_equal 0, Blockchain::Slot.where(network: "testnet").count
    assert_equal 0, Blockchain::Block.count
    assert_equal 0, Blockchain::Transaction.count
  end
end
