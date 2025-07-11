# frozen_string_literal: true

require "test_helper"

class ValidatorQueryTest < ActiveSupport::TestCase
  setup do
    @testnet_network = "testnet"
    @mainnet_network = "mainnet"
  end

  test "#initialize returns scope for web when api flag is false (default, less fields)" do
    query = ValidatorQuery.new
    sql = query.instance_variable_get("@default_scope").to_sql
    refute sql.include?("`validator_score_v1s`.`data_center_concentration_score`")
  end

  test "#initialize returns scope for api when api flag is true (more fields)" do
    query = ValidatorQuery.new(api: true)
    sql = query.instance_variable_get("@default_scope").to_sql
    assert sql.include?("`validator_score_v1s`.`data_center_concentration_score`")
  end

  test "#call returns only validators from correct network" do
    create_list(
      :validator,
      5,
      :with_score,
      :with_data_center_through_validator_ip,
      :mainnet
    )
    create_list(
      :validator,
      5,
      :with_score,
      :with_data_center_through_validator_ip
    )

    result = ValidatorQuery.new.call(network: @mainnet_network)

    assert_equal 5, result.count
    assert_equal [@mainnet_network], result.pluck(:network).uniq
  end

  test "#call returns only jito validators with commission below maximum, if jito param is provided" do
    create_list(
      :validator,
      2,
      :with_score,
      :with_data_center_through_validator_ip,
      :mainnet
    )
    create_list(
      :validator,
      3,
      :with_score,
      :with_data_center_through_validator_ip,
      :mainnet,
      jito: true,
      jito_commission: 800
    )
    create_list(
      :validator,
      1,
      :with_score,
      :with_data_center_through_validator_ip,
      :mainnet,
      jito: true,
      jito_commission: 1100
    )

    result = ValidatorQuery.new.call(network: @mainnet_network, query_params: { jito: true })

    assert_equal 3, result.count
    assert_equal [true], result.pluck(:jito).uniq
  end

  test "#call returns all validators without jito param" do
    create_list(
      :validator,
      2,
      :with_score,
      :with_data_center_through_validator_ip,
      :mainnet
    )
    create_list(
      :validator,
      3,
      :with_score,
      :with_data_center_through_validator_ip,
      :mainnet,
      jito: true
    )

    result = ValidatorQuery.new.call(network: @mainnet_network, query_params: { jito: false })

    assert_equal 5, result.count
  end

  test "#call returns only doublezero validators, if is_dz param is provided" do
    create_list(:validator, 2, :with_score, :with_data_center_through_validator_ip, :mainnet)
    create_list(:validator, 3, :with_score, :with_data_center_through_validator_ip, :mainnet, is_dz: true)

    result = ValidatorQuery.new.call(network: @mainnet_network, query_params: { is_dz: true })

    assert_equal 3, result.count
    assert_equal [true], result.pluck(:is_dz).uniq

    result = ValidatorQuery.new.call(network: @mainnet_network, query_params: { is_dz: false })

    assert_equal 5, result.count
  end

  test "#call returns only matching results when query is provided" do
    query = "test_account"

    create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: query
    )
    create_list(
      :validator,
      5,
      :with_score,
      :with_data_center_through_validator_ip
    )

    result = ValidatorQuery.new.call(network: @testnet_network, query_params: { query: query })

    assert_equal 1, result.count
    assert_equal [@testnet_network], result.pluck(:network).uniq
    assert_equal [query], result.pluck(:account).uniq
  end

  test "#call returns matching results if admin_warning is present" do
    validator_with_warning = create(:validator, :with_score, :with_admin_warning)
    create_list(:validator, 2, :with_score) # without admin_warning

    admin_warning = "true"
    result = ValidatorQuery.new.call(network: @testnet_network, query_params: { admin_warning: admin_warning })

    assert_equal 1, result.count
    assert_includes result, validator_with_warning
    assert_equal [@testnet_network], result.pluck(:network).uniq
    assert_equal ["test warning"],  result.pluck(:admin_warning).uniq

    admin_warning = "false"
    result = ValidatorQuery.new.call(network: @testnet_network, query_params: { admin_warning: admin_warning })

    refute_includes result, validator_with_warning
    assert_equal [nil], result.pluck(:admin_warning).uniq
  end

  test "#call ignores incorrect or missing admin_warning param" do
    Validator.destroy_all
    create(:validator, :with_score, :with_admin_warning)
    create_list(:validator, 5, :with_score) # without admin_warning
    all_validators_count = Validator.where(network: @testnet_network).count

    admin_warning = "ASD"
    result = ValidatorQuery.new.call(network: @testnet_network, query_params: { admin_warning: admin_warning })

    assert_equal all_validators_count, result.count

    admin_warning = nil
    result = ValidatorQuery.new.call(network: @testnet_network, query_params: { admin_warning: admin_warning })

    assert_equal all_validators_count, result.count
  end

  test "#call returns results in correct score order" do
    5.times do |n|
      v = create(
        :validator,
        :with_score,
        :mainnet,
        :with_data_center_through_validator_ip
      )
      v.score.update_column(:total_score,  n)
    end

    result = ValidatorQuery.new.call(network: @mainnet_network, sort_order: "score")

    assert_equal 5, result.count
    assert_equal [4, 3, 2, 1, 0], result.pluck("validator_score_v1s.total_score")
  end

  test "#call returns results in correct name order" do
    5.times do |n|
      create(
        :validator,
        :with_score,
        :mainnet,
        :with_data_center_through_validator_ip,
        name: "#{n}-validator"
      )
    end

    result = ValidatorQuery.new.call(network: @mainnet_network, sort_order: "name")

    assert_equal 5, result.count
    assert_equal (0..4).map{ |n| "#{n}-validator" }, result.pluck(:name)
  end

  test "#call_single_validator returns single validator" do
    validators = create_list(
      :validator,
      5,
      :with_score,
      :mainnet,
      :with_data_center_through_validator_ip,
    )

    validator = validators.first

    result = ValidatorQuery.new.call_single_validator(
      network: @mainnet_network,
      account: validator.account
    )

    assert_equal validator, result
  end

  test "#call returns correct user watchlist validators" do
    user = create(:user)
    validator = create(
      :validator,
      :with_score,
      :mainnet,
      :with_data_center_through_validator_ip
    )

    create(:user_watchlist_element, validator: validator, user: user)

    validators = create_list(
      :validator,
      5,
      :with_score,
      :mainnet,
      :with_data_center_through_validator_ip,
    )

    result = ValidatorQuery.new(watchlist_user: user.id).call(
      network: @mainnet_network
    )

    assert_equal 1, result.count
    assert_equal validator, result.first
  end

  test "#call returns results in correct score order with random_seed_val passed in" do
    validator = create(:validator, :with_score, network: @mainnet_network)
    create_list(:validator, 5, :with_score, network: @mainnet_network)

    result = ValidatorQuery.new.call(random_seed_val: 123)

    assert_equal validator, result.last

    result = ValidatorQuery.new.call(random_seed_val: 0)

    assert_equal validator, result.first
  end

  test "#call returns only active validators if active_only is true" do
    create_list(:validator, 5, :with_score, :mainnet, is_active: false)
    create_list(:validator, 5, :with_score, :mainnet, is_active: true)

    result = ValidatorQuery.new.call(
      network: @mainnet_network,
      query_params: { active_only: true }
    )

    assert_equal 5, result.count
    assert_equal [true], result.pluck(:is_active).uniq
  end

  test "#call returns only active validators if active_only parameter is not provided" do
    create_list(:validator, 5, :with_score, :mainnet, is_active: false)
    create_list(:validator, 5, :with_score, :mainnet, is_active: true)

    result = ValidatorQuery.new.call(
      network: @mainnet_network
    )

    assert_equal 5, result.count
    assert_equal [true], result.pluck(:is_active).uniq
  end

  test "#call returns all validators if active_only is false" do
    create_list(:validator, 5, :with_score, :mainnet, is_active: false)
    create_list(:validator, 5, :with_score, :mainnet, is_active: true)

    result = ValidatorQuery.new.call(
      network: @mainnet_network,
      query_params: { active_only: false }
    )

    assert_equal 10, result.count
    assert_equal [true, false], result.pluck(:is_active).uniq
  end

  test "#call ignores whitespaces in query" do
    query = " test_name "

    create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "test_account",
      name: "test_name"
    )

    result = ValidatorQuery.new.call(network: @testnet_network, query_params: { query: query })

    assert_equal 1, result.count
  end
end
