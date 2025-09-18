require "test_helper"

class PolicyTest < ActiveSupport::TestCase
  test "non_validators returns only policy_identities without validator (visible scope requires account)" do
    policy = create(:policy)
    p1 = create(:policy_identity, policy: policy, validator: nil, account: 'A')
    p2 = create(:policy_identity, policy: policy, account: 'B')
    p3 = create(:policy_identity, policy: policy, validator: nil, account: PolicyIdentity::ACCOUNT_BLACKLIST.first)

    result = policy.non_validators
    assert_includes result, p1
    refute_includes result, p2
    refute_includes result, p3
  end
end
