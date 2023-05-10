# frozen_string_literal: true

require "test_helper"

class ValidatorSearchQueryTest < ActiveSupport::TestCase
  def setup
    super

    current_version = "1.5.4"
    create(:batch, software_version: current_version, network: "searchnet")

    # Setup data centers with data center hosts
    data_center = create(:data_center, :china)
    data_center.update_column(:data_center_key, "Name1") # Update to match query
    data_center2 = create(:data_center, :berlin)

    data_center_host = create(:data_center_host, data_center: data_center)
    data_center_host2 = create(:data_center_host, data_center: data_center2)

    # Setup validators
    @validators_name1 = [
      create(:validator, :with_score, name: "Name1"),
      create(:validator, :with_score, account: "Name1Account"),
      create(:validator, :with_score, name: "Name1", network: "searchnet"),
      create(:validator, :with_score, account: "Name1Account", network: "searchnet"),
    ]

    @validators_name2 = [
      create(:validator, :with_score, name: "Name2"),
      create(:validator, :with_score, account: "Name2Account"),
      create(:validator, :with_score, name: "Name2", network: "searchnet"),
      create(:validator, :with_score, account: "Name2Account", network: "searchnet"),
      create(:validator, :with_score)
    ]

    @val1 = create(:validator, :with_score)
    @val2 = create(:validator, :with_score)
    @val3 = create(:validator, :with_score)

    # Setup VoteAccounts for validators
    create(:vote_account, validator: @val1, account: "Vote1Account")
    create(:vote_account, validator: @val2, account: "Vote2Account")
    create(:vote_account, validator: @val3, account: "Name1VoteAccount")

    @validators_name1.push @val3 # this has VoteAccount with started with "Name1"

    # Connect validators with desired data centers through data_center_hosts
    @validators_name1.each do |validator|
      create(:validator_ip, :active, validator: validator, data_center_host: data_center_host)
    end
    @validators_name2.each do |validator|
      create(:validator_ip, :active, validator: validator, data_center_host: data_center_host2)
    end
    [@val1, @val2].each do |validator|
      create(:validator_ip, :active, validator: validator, data_center_host: data_center_host2)
    end
  end

  test "returns validators with name/account/software_version/data_center_key or account like query (Name1)" do
    query   = "Name1"
    results = ValidatorSearchQuery.new.search(query)

    assert_equal results.to_a, @validators_name1
  end

  test "returns validators for query that is any part of validator name (ame1)" do
    query   = "ame1"
    results = ValidatorSearchQuery.new.search(query)

    assert_equal results.pluck(:name).uniq, ["Name1"]
  end

  test "returns validators only for network provided in the relation" do
    query    = "Name1"
    relation = Validator.where(network: "searchnet")
    results  = ValidatorSearchQuery.new(relation).search(query)

    assert_equal results, @validators_name1.values_at(2, 3)
  end

  test "returns validators with name/account/software_version/data_center_key or account like query (Name)" do
    query     = "Name"
    results   = ValidatorSearchQuery.new.search(query)

    assert_equal 9, results.count
  end

  test "returns proper results when search by vote account" do
    query = "Vote"
    results = ValidatorSearchQuery.new.search(query)

    assert_equal "Vote1Account", results.first.vote_accounts.first.account
    assert_equal "Vote2Account", results.last.vote_accounts.first.account
    assert_equal 2, results.count
  end

  test "returns proper results when search by software_version" do
    v = create(:validator)
    create(:validator_score_v1, validator: v, software_version: "1.6.9")
    query = "1.6.7"
    results = ValidatorSearchQuery.new.search(query)

    assert_equal ["1.6.7"], results.pluck(:software_version).uniq
  end

end
