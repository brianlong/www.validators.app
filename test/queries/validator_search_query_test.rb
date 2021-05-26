# frozen_string_literal: true
require 'test_helper'

class ValidatorSearchQueryTest < ActiveSupport::TestCase
  def setup
    super

    @validators = [
      create(:validator, :with_score, name: 'Name1'),
      create(:validator, :with_score, name: 'Name2'),
      create(:validator, :with_score, account: 'Name1Account'),
      create(:validator, :with_score, account: 'Name2Account'),
      create(:validator, :with_score, name: 'Name1', network: 'searchnet'),
      create(:validator, :with_score, name: 'Name2', network: 'searchnet'),
      create(:validator, :with_score, account: 'Name1Account', network: 'searchnet'),
      create(:validator, :with_score, account: 'Name2Account', network: 'searchnet'),
      create(:validator)
    ]

    @validators.last.validator_score_v1 =
      create(:validator_score_v1, data_center_key: 'Name1Center')
  end

  def teardown
    super

    @validators.each(&:destroy)
  end

  test 'returns proper results for Validator.all' do
    query   = 'Name1'
    results = ValidatorSearchQuery.new.search(query)

    assert_equal results, @validators.values_at(0, 2, 4, 6, 8)
  end

  test 'returns proper results for provided relation' do
    query    = 'Name1'
    relation = Validator.where(network: 'searchnet')
    results  = ValidatorSearchQuery.new(relation).search(query)

    assert_equal results, @validators.values_at(4, 6)
  end
end
