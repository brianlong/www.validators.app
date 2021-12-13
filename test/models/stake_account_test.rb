require "test_helper"

class StakeAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @stake_account = build(:stake_account)
  end

  test "#formatted_delegated_stake" do
    @stake_account.delegated_stake = 1231241947819748172
    assert_equal "1,231,241,947.82", @stake_account.formatted_delegated_stake
  end
end
