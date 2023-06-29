require "test_helper"

class AccountAuthorityQueryTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"

    @validator = create(:validator, network: @network, account: "test_validator")
    @vote_account = create(
      :vote_account,
      validator: @validator,
      network: @network,
      authorized_voters: { "test_voter_key" => "test_voter_value" }
    )

    @validator2 = create(:validator, network: @network, account: "test_validator2")

    4.times do
      create(:vote_account, network: @network, authorized_voters: { "test_voter_key" => "test_voter_value" })
    end

    create(:vote_account, network: "pythnet", authorized_voters: { "test_voter_key" => "test_voter_value" })
  end

  test "#call provides results from the given network" do
    VoteAccount.where(network: @network).each do |va|
      va.update(authorized_voters: { "test_withdrawer_key2" => "test_withdrawer_value2" })
    end
    res = AccountAuthorityQuery.new(network: @network).call

    assert_equal 5, res.count
    assert_equal [@network], res.pluck(:network).uniq
  end

  test "#call provides results from the correct validator if validator param is provided" do
    @vote_account.update(authorized_voters: { "test_withdrawer_key2" => "test_withdrawer_value2" })
    res = AccountAuthorityQuery.new(network: @network, validator: @validator.account).call

    assert_equal 1, res.count
    assert_equal @validator, res.first.vote_account.validator
  end

  test "#call provides results from the correct vote_account if vote_account param is provided" do
    @vote_account.update(authorized_voters: { "test_withdrawer_key2" => "test_withdrawer_value2" })
    res = AccountAuthorityQuery.new(network: @network, vote_account: @vote_account.account).call

    assert_equal 1, res.count
    assert_equal @vote_account, res.first.vote_account
  end

  test "#call does no return record where only nil value changed" do
    @vote_account.update(authorized_withdrawer: SecureRandom.hex(16))
    res = AccountAuthorityQuery.new(network: @network, vote_account: @vote_account.account).call

    assert_equal 0, res.count
  end

  test "#call raises error when validator and vote_account params do not match" do
    assert_raises ArgumentError do
      AccountAuthorityQuery.new(
        network: @network,
        vote_account: @vote_account.account,
        validator: @validator2.account
      ).call
    end
  end
end
