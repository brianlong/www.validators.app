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

    @validators.last.score = create(:validator_score_v2, data_center_key: 'Name1Center')

    val1 = create(:validator, :with_score)
    val2 = create(:validator, :with_score)
    val3 = create(:validator, :with_score)

    @validators.push val3

    create(:vote_account, validator: val1, account: 'Vote1Account')
    create(:vote_account, validator: val2, account: 'Vote2Account')
    create(:vote_account, validator: val3, account: 'Name1VoteAccount')
  end

  def teardown
    super

    @validators.each(&:destroy)
  end

  test 'returns proper results for Validator.all' do
    query   = 'Name1'
    results = ValidatorSearchQuery.new.search(query)

    assert_equal results, @validators.values_at(0, 2, 4, 6, 8, 9)
  end

  test 'returns proper results for provided relation' do
    query    = 'Name1'
    relation = Validator.where(network: 'searchnet')
    results  = ValidatorSearchQuery.new(relation).search(query)

    assert_equal results, @validators.values_at(4, 6)
  end

  test 'returns proper results when search by all fields' do
    query     = 'Name'
    results   = ValidatorSearchQuery.new.search(query)

    assert_equal 10, results.count
  end

  test 'returns proper results when search by vote account' do
    query = 'Vote'
    results = ValidatorSearchQuery.new.search(query)

    assert_equal 'Vote1Account', results.first.vote_accounts.first.account
    assert_equal 'Vote2Account', results.last.vote_accounts.first.account
    assert_equal 2, results.count
  end

  test 'returns proper results when search by software_version' do
    v = create(:validator)
    create(:validator_score_v2, validator: v, software_version: '1.6.9')
    query = '1.6.7'
    results = ValidatorSearchQuery.new.search(query)

    assert_equal ['1.6.7'], results.pluck(:software_version).uniq
  end

end
