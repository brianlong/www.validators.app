# frozen_string_literal: true

require "test_helper"

class Blockchain::BlockTest < ActiveSupport::TestCase
  test "#network returns correct child class" do
    assert_equal Blockchain::Block.network("mainnet").to_s, "Blockchain::MainnetBlock"
    assert_equal Blockchain::Block.network("testnet").to_s, "Blockchain::TestnetBlock"
  end

  test "#network raises error for invalid network" do
    assert_raises ArgumentError do
      Blockchain::Block.network("invalid")
    end
  end

  test "#count returns correct count" do
    create(:mainnet_block)
    create_list(:testnet_block, 2)

    assert_equal Blockchain::Block.count, 3
  end
end
