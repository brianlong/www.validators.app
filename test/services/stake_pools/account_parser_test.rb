# frozen_string_literal: true

require "test_helper"

module StakePools
  class AccountParserTest < ActiveSupport::TestCase
    def pubkey
      "\x01".b * 32
    end

    def fee(numerator, denominator)
      [denominator, numerator].pack("Q<Q<")
    end

    def build_account(account_type: 1, next_manager_fee: nil, preferred_validator: false, next_withdrawal_fee: nil)
      data = [account_type].pack("C")
      data += pubkey * 3 + [255].pack("C") + pubkey * 5
      data += [1_310_000_000_000, 1_000_000_000_000, 1082].pack("Q<Q<Q<")
      data += [0, 0].pack("q<Q<") + pubkey
      data += fee(4, 100)
      data += next_manager_fee ? [2].pack("C") + fee(*next_manager_fee) : [0].pack("C")
      data += preferred_validator ? [1].pack("C") + pubkey : [0].pack("C")
      data += [0].pack("C")
      data += fee(1, 1000) + fee(1, 1000)
      data += [0].pack("C")
      data += [0].pack("C")
      data += [1].pack("C") + pubkey
      data += fee(5, 10_000)
      data += [0].pack("C")
      data += [0].pack("C")
      data += fee(1, 1000)
      data += next_withdrawal_fee ? [1].pack("C") + fee(*next_withdrawal_fee) : [0].pack("C")
      data += [0, 0].pack("Q<Q<")
      Base64.strict_encode64(data)
    end

    test "parses fees and token data from stake pool account" do
      result = AccountParser.new(build_account).call

      assert_equal 1_310_000_000_000, result[:total_lamports]
      assert_equal 1_000_000_000_000, result[:pool_token_supply]
      assert_equal 4.0, result[:manager_fee]
      assert_nil result[:next_manager_fee]
      assert_equal 0.05, result[:deposit_fee]
      assert_equal 0.1, result[:withdrawal_fee]
      assert_nil result[:next_withdrawal_fee]
    end

    test "parses scheduled fee changes and optional pubkeys" do
      result = AccountParser.new(
        build_account(next_manager_fee: [7, 100], preferred_validator: true, next_withdrawal_fee: [3, 1000])
      ).call

      assert_equal 4.0, result[:manager_fee]
      assert_equal 7.0, result[:next_manager_fee]
      assert_equal 0.05, result[:deposit_fee]
      assert_equal 0.1, result[:withdrawal_fee]
      assert_equal 0.3, result[:next_withdrawal_fee]
    end

    test "raises error for non stake pool account" do
      assert_raises(AccountParser::InvalidAccount) do
        AccountParser.new(build_account(account_type: 2)).call
      end
    end

    test "raises error for truncated data" do
      assert_raises(AccountParser::InvalidAccount) do
        AccountParser.new(Base64.strict_encode64([1].pack("C") + pubkey)).call
      end
    end
  end
end
