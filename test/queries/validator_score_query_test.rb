require 'test_helper'

# Query Objects for searching for ValidatorHistory relations and objects
class ValidatorScoreQueryTest < ActiveSupport::TestCase
  def setup
    super

    batch_uuid = create(:batch).uuid
    srand(123_456)
    @validators = [
      create(:validator, :with_score),
      create(:validator, :with_score),
      create(:validator, :with_score),
      create(:validator, :with_score),
      create(:validator, :with_score),
      create(:validator, :with_score)
    ]

    @validator_histories = @validators.map do |validator|
      create(:validator_history, batch_uuid: batch_uuid,
                                 account: validator.account, root_block: 2,
                                 last_vote: 21, active_stake: 10)
    end
    @validator_scores = @validators.map(&:score)
    @validator_scores.last.update(active_stake: nil)

    @vsq = ValidatorScoreQuery.new('testnet', batch_uuid)
  end

  def teardown
    super

    @validator_histories.each(&:destroy)
  end

  test 'top_staked_validators' do
    expected = [206356743325616, 206356743325097, 206356743324143,
                206356743322528, 206356743321847, 0]

    assert_equal expected, @vsq.top_staked_validators
  end

  test 'root_distance_stats' do
    expected = {
      min: 3.0,
      max: 3.0,
      median: 3.0,
      average: 3.0
    }
    assert_equal expected, @vsq.root_distance_stats
  end

  test 'root_distance_stats with_history' do
    expected = {
      min: 3.0,
      max: 3.0,
      median: 3.0,
      average: 3.0,
      history: [
        [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5],
        [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5]
      ]
    }

    assert_equal expected, @vsq.root_distance_stats(with_history: true)
  end

  test 'vote_distance_stats' do
    expected = {
      min: 3.0,
      max: 3.0,
      median: 3.0,
      average: 3.0
    }

    assert_equal expected, @vsq.vote_distance_stats
  end

  test 'vote_distance_stats with_history' do
    expected = {
      min: 3.0,
      max: 3.0,
      median: 3.0,
      average: 3.0,
      history: [
        [5, 4, 3, 2, 1], [5, 4, 3, 2, 1], [5, 4, 3, 2, 1],
        [5, 4, 3, 2, 1], [5, 4, 3, 2, 1], [5, 4, 3, 2, 1]
      ]
    }

    assert_equal expected, @vsq.vote_distance_stats(with_history: true)
  end
end

