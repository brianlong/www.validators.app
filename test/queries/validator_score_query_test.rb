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

  test 'for_batch' do
    expected = ValidatorScoreV1.where(validator_id: @validators.map(&:id))

    assert_equal expected, @vsq.for_batch
  end
end

