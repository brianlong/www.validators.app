# frozen_string_literal: true

require "test_helper"

class Blockchain::SlotTest < ActiveSupport::TestCase
  test "#network returns correct child class" do
    assert_equal Blockchain::Slot.network("mainnet").to_s, "Blockchain::MainnetSlot"
    assert_equal Blockchain::Slot.network("testnet").to_s, "Blockchain::TestnetSlot"
    assert_equal Blockchain::Slot.network("pythnet").to_s, "Blockchain::PythnetSlot"
  end

  test "#network raises error for invalid network" do
    assert_raises ArgumentError do
      Blockchain::Slot.network("invalid")
    end
  end

  test "#count returns correct count" do
    create(:mainnet_slot)
    create_list(:testnet_slot, 2)
    create_list(:pythnet_slot, 3)

    assert_equal Blockchain::Slot.count, 6
  end
end
