# frozen_string_literal: true

require "test_helper"

class Blockchain::BlockFooterTest < ActiveSupport::TestCase
  test ".network returns footer model for supported networks" do
    assert_equal Blockchain::AlpenglowCommunityBlockFooter, Blockchain::BlockFooter.network("alpenglow-community")
    assert_equal Blockchain::TestnetBlockFooter, Blockchain::BlockFooter.network("testnet")
  end

  test ".network raises for networks without block footers" do
    assert_raises(ArgumentError) { Blockchain::BlockFooter.network("mainnet") }
  end
end
