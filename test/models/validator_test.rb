# frozen_string_literal: true

require 'test_helper'

class ValidatorTest < ActiveSupport::TestCase
  def setup
    @validator = create(:validator)
    @validator_ip = create(:validator_ip, :active, validator: @validator)
  end

  test 'relationships has_one most_recent_epoch_credits_by_account' do
    validator = create(:validator)
    create_list(:validator_history, 5, account: validator.account, epoch_credits: 100)

    assert_equal 100, validator.most_recent_epoch_credits_by_account.epoch_credits
  end

  test "relationships has_one data_center_host through validator_ips" do
    validator = create(:validator)
    data_center_host = create(:data_center_host)
    validator_ip = create(:validator_ip, :active, validator: validator, data_center_host: data_center_host)
    
    assert_equal data_center_host, validator.validator_ip_active.data_center_host
  end

  test "relationships has_one validator_ip_active" do
    validator = create(:validator)
    validator_ip = create(:validator_ip, validator: validator)
    validator_ip2 = create(:validator_ip, :active, validator: validator)
    
    assert_equal validator_ip2, validator.validator_ip_active
  end

  # API relationships
  test "relationships for api has_many vote_accounts_for_api" do
    validator = create(:validator)
    vote_account = create(:vote_account, validator: validator)

    assert_equal ["account", "validator_id", "id"], validator.vote_accounts_for_api.first.attributes.keys
  end

  test "relationships for api has_one validator_ip_active_for_api" do
    validator = create(:validator)
    validator_ip = create(:validator_ip, validator: validator)
    validator_ip2 = create(:validator_ip, :active, :with_data_center, validator: validator)
    
    assert_equal ["id", "address", "data_center_host_id", "validator_id"], validator.validator_ip_active_for_api.attributes.keys
  end

  test "relationships for api has_one data_center_host_for_api through: :validator_ip_active_for_api" do
    validator = create(:validator)
    validator_ip = create(:validator_ip, :with_data_center, validator: validator)
    validator_ip2 = create(:validator_ip, :active, :with_data_center, validator: validator)

    assert_equal ["id", "host", "data_center_id"], validator.validator_ip_active_for_api.data_center_host_for_api.attributes.keys
  end

  test "relationships for api has_one data_center_for_api through: :data_center_host_for_api" do
    validator = create(:validator)
    validator_ip = create(:validator_ip, :with_data_center, validator: validator)
    validator_ip2 = create(:validator_ip, :active, :with_data_center, validator: validator)

    assert_equal ["data_center_key", "id", "location_latitude", "location_longitude", "traits_autonomous_system_number"], 
                 validator.data_center_host_for_api.data_center_for_api.attributes.keys.sort
  end


  test '#api_url creates correct link for test environment' do
    validator = build(:validator)
    expected_url = "http://localhost:3000/api/v1/validators/#{validator.network}/#{validator.account}"

    assert_equal expected_url, validator.api_url
  end

  test 'ping_times_to' do
    assert_equal 3, validators(:one).ping_times_to.count
  end

  test 'ping_times_to_avg' do
    assert_equal 75.0, validators(:one).ping_times_to_avg
  end

  test '#private_validator? returns true if validator\'s commission is 100%' do
    validator = create(:validator, network: 'mainnet')
    assert create(:validator_score_v1, commission: 100, validator: validator).validator.private_validator?
    refute create(:validator_score_v1, commission: 99, validator: validator).validator.private_validator?
  end

  test 'lido? returns true if name starts with Lido' do
    validator = create(:validator, network: 'mainnet', name: 'Lido / Everstake')
    assert_equal true, validator.lido?
    validator.update(name: 'IAmNotLido')
    assert_equal false, validator.lido?
    validator.update(name: '')
    assert_equal false, validator.lido?
  end

  test 'validator attributes are correctly stored in db after using utf_8_encode method' do
    special_chars_sentence = 'Staking-P◎◎l FREE Validati◎n'

    v = Validator.create(
      name: special_chars_sentence.encode_utf_8,
      details: special_chars_sentence.encode_utf_8
    )

    assert_equal special_chars_sentence, v.name
    assert_equal special_chars_sentence, v.details
  end

  test "#vip_address returns validator ip address" do
    assert_equal @validator_ip.address, @validator.vip_address
  end
end
