# frozen_string_literal: true

require "test_helper"

class CheckGroupValidatorAssignmentServiceTest < ActiveSupport::TestCase
  def setup
    @network = "mainnet"
    @group1 = create(:group, network: @network)
    @validator1 = create(:validator, group: @group1, network: @network)
    @vote_account1 = create(
      :vote_account,
      validator: @validator1,
      network: @network,
      validator_identity: "validator_identity_test",
      authorized_withdrawer: "authorized_withdrawer_test",
      authorized_voters: { 123 => "test_voter_value" }
    )
  end

  test "#call does not assign validator to a group if there are no matches" do
    validator = create(:validator, network: @network)
    vote_account = create(:vote_account, validator: validator, network: @network)

    CheckGroupValidatorAssignmentService.new(vote_account_id: vote_account.id).call
    refute validator.group
    assert_equal 1, Group.count
    assert_equal @network, Group.first.network
  end

  test "#call assigns validator to a group if there are validators that matches by identity" do
    validator = create(:validator, network: @network)
    vote_account = create(
      :vote_account,
      validator: validator,
      network: @network,
      validator_identity: "validator_identity_test"
    )

    CheckGroupValidatorAssignmentService.new(vote_account_id: vote_account.id).call
    validator.reload
    assert validator.group
    assert_equal @group1, validator.group
    assert_equal 1, Group.count
    assert_equal @network, Group.first.network
  end

  test "#call assigns validator to a group if there are validators that matches by withdrawer" do
    validator = create(:validator, network: @network)
    vote_account = create(
      :vote_account,
      validator: validator,
      network: @network,
      authorized_withdrawer: "authorized_withdrawer_test"
    )

    CheckGroupValidatorAssignmentService.new(vote_account_id: vote_account.id).call
    validator.reload
    assert validator.group
    assert_equal @group1, validator.group
    assert_equal 1, Group.count
    assert_equal @network, Group.first.network
  end

  test "#call assigns validator to a group if there are validators that matches by voters" do
    validator = create(:validator, network: @network)
    vote_account = create(
      :vote_account,
      validator: validator,
      network: @network,
      authorized_voters: { 123 => "test_voter_value" }
    )

    CheckGroupValidatorAssignmentService.new(vote_account_id: vote_account.id).call
    validator.reload
    assert validator.group
    assert_equal @group1, validator.group
    assert_equal 1, Group.count
    assert_equal @network, Group.first.network
  end

  test "#call destroys empty groups" do
    group2 = create(:group)
    validator = create(:validator, network: @network, group: group2)
    vote_account = create(
      :vote_account,
      validator: validator,
      network: @network,
      authorized_voters: { 123 => "test_voter_value" }
    )
    puts Group.count
    CheckGroupValidatorAssignmentService.new(vote_account_id: vote_account.id).call

    assert_equal 1, Group.count
  end
end
