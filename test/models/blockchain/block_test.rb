# frozen_string_literal: true

require "test_helper"

class Blockchain::BlockTest < ActiveSupport::TestCase
  test "#network returns correct child class" do
    assert_equal Blockchain::Block.network("mainnet").to_s, "Blockchain::MainnetBlock"
    assert_equal Blockchain::Block.network("testnet").to_s, "Blockchain::TestnetBlock"
    assert_equal Blockchain::Block.network("pythnet").to_s, "Blockchain::PythnetBlock"
  end

  test "#network raises error for invalid network" do
    assert_raises ArgumentError do
      Blockchain::Block.network("invalid")
    end
  end

  test "#count returns correct count" do
    create(:mainnet_block)
    create_list(:testnet_block, 2)
    create_list(:pythnet_block, 3)

    assert_equal Blockchain::Block.count, 6
  end
end
