# frozen_string_literal: true

require "test_helper"

class ValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = create(:validator)

    @va1 = create(
      :vote_account,
      validator: @validator,
      updated_at: 1.minute.ago,
      is_active: true,
      account: "test1"
    )
    @va2 = create(
      :vote_account,
      validator: @validator,
      is_active: true,
      account: "test2"
    )
    @va3 = create(
      :vote_account,
      validator: @validator,
      is_active: false,
      account: "test3"
    )

    @score = create(:validator_score_v1, validator: @validator)

    @v_delinquent = create(:validator, account: "v_delinquent")
    create(:validator_score_v1, validator: @v_delinquent, delinquent: true)

    @v_private = create(:validator, account: "v_private")
    create(:validator_score_v1, validator: @v_private, commission: 100)
  end

  test "relationship has_one data_center_host through validator_ips" do
    data_center_host = create(:data_center_host)
    create(:validator_ip, :active, validator: @validator, data_center_host: data_center_host)

    assert_equal data_center_host, @validator.validator_ip_active.data_center_host
  end

  test "relationship has_one validator_ip_active" do
    validator_ip = create(:validator_ip, validator: @validator)
    validator_ip2 = create(:validator_ip, :active, validator: @validator)

    assert_equal validator_ip2, @validator.validator_ip_active
  end

  test "relationship has_one validator_score_v1_for_web returns only fields required for validators index page" do
    fields = ValidatorScoreV1::FIELDS_FOR_VALIDATORS_INDEX_WEB
    validator_score_v1 = @validator.validator_score_v1_for_web

    assert_equal fields, validator_score_v1.attributes.keys.map(&:to_sym) - [:id]
  end

  test "relationship has_one validator_score_v1_for_api returns only fields required for validators index api" do
    fields = ValidatorScoreV1::FIELDS_FOR_API
    validator_score_v1 = @validator.validator_score_v1_for_api

    assert_equal fields, validator_score_v1.attributes.keys.map(&:to_sym) - [:id]
  end

  # API relationships
  test "relationship for api has_many vote_accounts_for_api" \
       "returns vote_account with specified fields" do
    vote_account = create(:vote_account, validator: @validator)

    assert_equal VoteAccount::FIELDS_FOR_API.map(&:to_s), @validator.vote_accounts_for_api.first.attributes.keys
  end

  test "relationship has_one validator_ip_active_for_api" \
       "returns validator_ip_active wirh specified fields" do
    validator_ip = create(:validator_ip, :active, :with_data_center, validator: @validator)

    assert_equal validator_ip, @validator.validator_ip_active_for_api
    assert_equal ValidatorIp::FIELDS_FOR_API.map(&:to_s), @validator.validator_ip_active_for_api.attributes.keys
  end

  test "relationship has_one data_center_host_for_api through: :validator_ip_active_for_api" \
       "returns data_center_host with specified fields" do
    validator_ip = create(:validator_ip, :active, :with_data_center, validator: @validator)

    assert_equal validator_ip.data_center_host, @validator.data_center_host_for_api
    assert_equal DataCenterHost::FIELDS_FOR_API.map(&:to_s),
      @validator.validator_ip_active_for_api.data_center_host_for_api.attributes.keys
  end

  test "relationship has_one data_center_for_api through: :data_center_host_for_api"\
        "returns data_center with specified fields" do
    validator_ip = create(:validator_ip, :active, :with_data_center, validator: @validator)

    assert_equal validator_ip.data_center_host.data_center, @validator.data_center_for_api
    assert_equal DataCenter::FIELDS_FOR_API.map(&:to_s),
      @validator.data_center_host_for_api.data_center_for_api.attributes.keys.sort
  end
  # /API relationships

  test "#api_url creates correct link for test environment" do
    expected_url = "http://localhost:3000/api/v1/validators/#{@validator.network}/#{@validator.account}"

    assert_equal expected_url, @validator.api_url
  end

  test "#private_validator? returns true if validator's commission is 100%" do
    @validator.update(network: 'mainnet')

    assert create(:validator_score_v1, commission: 100, validator: @validator).validator.private_validator?
    refute create(:validator_score_v1, commission: 99, validator: @validator).validator.private_validator?
  end

  test "#jito_maximum_commission? returns true if validator is jito and jito commission is below or equal 10%" do
    @validator.update(jito: false)
    refute @validator.jito_maximum_commission?

    @validator.update(jito: false, jito_commission: nil)
    refute @validator.jito_maximum_commission?

    @validator.update(jito: true, jito_commission: nil)
    assert @validator.jito_maximum_commission?

    @validator.update(jito: true, jito_commission: 800)
    assert @validator.jito_maximum_commission?

    @validator.update(jito: true, jito_commission: 1000)
    assert @validator.jito_maximum_commission?

    @validator.update(jito: true, jito_commission: 1100)
    refute @validator.jito_maximum_commission?
  end

  test "validator attributes are correctly stored in db after using utf_8_encode method" do
    special_chars_sentence = "Staking-P◎◎l FREE Validati◎n"

    @validator.update(
      name: special_chars_sentence.encode_utf_8,
      details: special_chars_sentence.encode_utf_8
    )

    assert_equal special_chars_sentence, @validator.name
    assert_equal special_chars_sentence, @validator.details
  end

  test "#vip_address returns validator ip address" do
    validator_ip = create(:validator_ip, :active, validator: @validator)

    assert_equal validator_ip.address, @validator.vip_address
  end

  test "#vote_account_active returns correct vote account" do

    assert_equal @va2, @validator.vote_account_active
  end

  test "#set_active_vote_account updates vote_accounts correctly" do
    @validator.set_active_vote_account(@va1)

    assert @va1.reload.is_active
    refute @va2.reload.is_active
    refute @va3.reload.is_active
  end

  test "#filtered_by delinquent provided with a string returns correct values" do
    result = Validator.filtered_by("delinquent")

    assert_equal 1, result.count
    assert result.last.delinquent?
  end

  test "#filtered_by delinquent includes all delinquent validators in collection" do
    result = Validator.filtered_by(["delinquent"])

    assert_equal 1, result.count
    assert result.last.delinquent?
  end

  test "#filtered_by active includes all active validators in collection" do
    result = Validator.filtered_by(["active"])

    assert_equal 3, result.count
    assert result.last.is_active
  end

  test "#filtered_by private includes all private validators in collection" do
    result = Validator.filtered_by(["private"])

    assert_equal 1, result.count
    assert_equal 100, result.last.score.commission
  end

  test "#filtered_by multiple parameters \
        includes all validators that meet any of selected criteria" do
    result = Validator.filtered_by(["delinquent", "private"])

    assert_equal 2, result.count
    assert result.include?(@v_private)
    assert result.include?(@v_delinquent)
  end

  test "responds to watchers correctly" do
    u = create(:user)
    create(:user_watchlist_element, validator: @validator, user: u)

    assert_equal u, @validator.watchers.first
  end

  test "#scope for_api returns correct fields" do
    val = Validator.for_api.first

    assert_equal Validator::FIELDS_FOR_API, val.attributes.keys.map(&:to_sym)
  end

  test "#commission_histories_exist returns true if there are commission changes created in last 60 days" do
    create(:commission_history, validator: @validator)
    assert @validator.commission_histories_exist
  end

  test "#commission_histories_exist returns false if there are no commission changes or older than 60 days" do
    refute @validator.commission_histories_exist

    create(:commission_history, validator: @validator, created_at: 370.days.ago)
    refute @validator.commission_histories_exist
  end

  test "deleting validator also deletes associated PolicyIdentity" do
    validator = create(:validator)
    policy_identity = create(:policy_identity, validator: validator)

    assert PolicyIdentity.exists?(policy_identity.id)

    validator.destroy

    refute PolicyIdentity.exists?(policy_identity.id)
  end
end
