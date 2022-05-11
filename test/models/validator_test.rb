# frozen_string_literal: true

require 'test_helper'

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
  end

  test 'relationship has_one most_recent_epoch_credits_by_account' do
    create_list(:validator_history, 5, account: @validator.account, epoch_credits: 100)

    assert_equal 100, @validator.most_recent_epoch_credits_by_account.epoch_credits
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

  test '#api_url creates correct link for test environment' do
    expected_url = "http://localhost:3000/api/v1/validators/#{@validator.network}/#{@validator.account}"

    assert_equal expected_url, @validator.api_url
  end

  test 'ping_times_to' do
    assert_equal 3, validators(:one).ping_times_to.count
  end

  test 'ping_times_to_avg' do
    assert_equal 75.0, validators(:one).ping_times_to_avg
  end

  test '#private_validator? returns true if validator\'s commission is 100%' do
    @validator.update(network: 'mainnet')

    assert create(:validator_score_v1, commission: 100, validator: @validator).validator.private_validator?
    refute create(:validator_score_v1, commission: 99, validator: @validator).validator.private_validator?
  end

  test 'lido? returns true if name starts with Lido' do
    @validator.update(network: 'mainnet', name: 'Lido / Everstake')
    assert @validator.lido?

    @validator.update(name: 'IAmNotLido')
    refute @validator.lido?

    @validator.update(name: "")
    refute @validator.lido?
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

  test "vote_account_active should return correct vote account" do

    assert_equal @va2, @validator.vote_account_active
  end

  test "set_active_vote_account updates vote_accounts correctly" do
    @validator.set_active_vote_account(@va1.account)

    assert @va1.reload.is_active
    refute @va2.reload.is_active
    refute @va3.reload.is_active
  end
end
