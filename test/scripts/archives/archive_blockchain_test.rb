# frozen_string_literal: true

require 'test_helper'

class ArchiveBlockchainTest < ActiveSupport::TestCase
  test 'archives blockchain data' do
    create(:epoch_wall_clock, epoch: 342, network: "testnet")

    slot = create(:testnet_slot, epoch: 335)
    block = create(:testnet_block, slot_number: slot.slot_number, epoch: 335)
    create(:testnet_transaction, slot_number: slot.slot_number, block_id: block.id, epoch: 335)

    load(Rails.root.join('script', 'archives', 'archive_blockchain.rb'))

    assert_equal 0, Blockchain::TestnetSlot.count
    assert_equal 0, Blockchain::TestnetBlock.count
    assert_equal 0, Blockchain::TestnetTransaction.count
  end
end
