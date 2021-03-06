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

  test 'validator attributes are correctly stored in db after using utf_8_encode method' do
    special_chars_sentence = 'Staking-P◎◎l FREE Validati◎n'

    v = Validator.create(
      name: special_chars_sentence.encode_utf_8,
      details: special_chars_sentence.encode_utf_8
    )

    assert_equal special_chars_sentence, v.name
    assert_equal special_chars_sentence, v.details
  end
end
