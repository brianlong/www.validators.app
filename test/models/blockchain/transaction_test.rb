# frozen_string_literal: true

require "test_helper"

class Blockchain::TransactionTest < ActiveSupport::TestCase
  test "#network returns correct child class" do
    assert_equal Blockchain::Transaction.network("mainnet").to_s, "Blockchain::MainnetTransaction"
    assert_equal Blockchain::Transaction.network("testnet").to_s, "Blockchain::TestnetTransaction"
  end

  test "#network raises error for invalid network" do
    assert_raises ArgumentError do
      Blockchain::Transaction.network("invalid")
    end
  end

  test "#count returns correct count" do
    create(:mainnet_transaction)
    create_list(:testnet_transaction, 2)

    assert_equal Blockchain::Transaction.count, 3
  end
end
