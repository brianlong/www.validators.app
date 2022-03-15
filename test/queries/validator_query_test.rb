# frozen_string_literal: true

require "test_helper"

class ValidatorQueryTest < ActiveSupport::TestCase
  setup do
    @testnet_network = "testnet"
    @mainnet_network = "mainnet"
  end

  test "ValidatorQuery returns only validators from correct network" do
    create_list(
      :validator, 
      5, 
      :with_score,
      :with_validator_ip_active_and_data_center,
      :mainnet
    )
    create_list(
      :validator, 
      5, 
      :with_score, 
      :with_validator_ip_active_and_data_center
    )

    result = ValidatorQuery.new.call(network: @mainnet_network)

    assert_equal 5, result.count
    assert_equal [@mainnet_network], result.pluck(:network).uniq
  end

  test "ValidatorQuery when query is provided returns only matching results" do
    query = "test_account"

    create(
      :validator, 
      :with_score,
      :with_validator_ip_active_and_data_center,
      account: query
    )
    create_list(
      :validator, 
      5, 
      :with_score,
      :with_validator_ip_active_and_data_center
    )

    result = ValidatorQuery.new.call(network: @testnet_network, query: query)

    assert_equal 1, result.count
    assert_equal [@testnet_network], result.pluck(:network).uniq
    assert_equal [query], result.pluck(:account).uniq
  end

  test "ValidatorQuery returns results in correct score order" do
    5.times do |n|
      v = create(
        :validator, 
        :with_score,
        :mainnet,
        :with_validator_ip_active_and_data_center
      )
      v.score.update_column(:total_score,  n)
    end

    result = ValidatorQuery.new.call(network: @mainnet_network, sort_order: "score")

    assert_equal 5, result.count
    assert_equal [4, 3, 2, 1, 0], result.pluck(:total_score)
  end

  test "ValidatorQuery returns results in correct stake order" do
    5.times do |n|
      v = create(
        :validator, 
        :with_score,
        :mainnet,
        :with_validator_ip_active_and_data_center
      )
      v.score.update_column(:active_stake,  n * 1000)
    end

    result = ValidatorQuery.new.call(network: @mainnet_network, sort_order: "score")

    assert_equal 5, result.count
    assert_equal (0..4).map{|n| n * 1000}.reverse, result.map{ |v| v.score.active_stake }
  end

  test "ValidatorQuery returns results in correct name order" do
    5.times do |n|
      create(
        :validator, 
        :with_score,
        :mainnet,
        :with_validator_ip_active_and_data_center,
        name: "#{n}-validator"
      )
    end

    result = ValidatorQuery.new.call(network: @mainnet_network, sort_order: "name")

    assert_equal 5, result.count
    assert_equal (0..4).map{ |n| "#{n}-validator" }, result.pluck(:name)
  end

end