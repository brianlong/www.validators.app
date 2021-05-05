# frozen_string_literal: true

require 'test_helper'

class ValidatorTest < ActiveSupport::TestCase
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
end
