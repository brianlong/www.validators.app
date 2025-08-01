# frozen_string_literal: true

require 'test_helper'

class UpdatePoliciesServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @validator = create(:validator, account: 'validator_account_1')
    @policy_data = {
      'pubkey' => 'policy_pubkey_1',
      'owner' => 'owner1',
      'lamports' => 123,
      'rent_epoch' => 1,
      'executable' => false,
      'data' => {
        'kind' => 1,
        'strategy' => false,
        'identities' => [@validator.account]
      },
      'token_metadata' => {
        'name' => 'Test Policy',
        'uri' => nil,
        'mint' => 'mint1',
        'symbol' => 'TST',
        'additionalMetadata' => { foo: 'bar' }
      }
    }
  end

  test 'creates and updates policy and identities' do
    assert_difference('Policy.count', 1) do
      assert_difference('PolicyIdentity.count', 1) do
        UpdatePoliciesService.new(policies: [@policy_data], network: 'mainnet').call
      end
    end
    policy = Policy.find_by(pubkey: 'policy_pubkey_1')
    assert_equal 'owner1', policy.owner
    assert_equal 123, policy.lamports
    assert_equal "v2", policy.kind
    assert_equal false, policy.strategy
    assert_equal 'Test Policy', policy.name
    assert_equal 'mint1', policy.mint
    assert_equal 'TST', policy.symbol
    assert_equal({ 'foo' => 'bar' }, policy.additional_metadata)
    assert_equal [@validator.account], policy.policy_identities.pluck(:account)
  end

  test 'removes policies not present in input' do
    old_policy = create(:policy, pubkey: 'old_pubkey', network: 'mainnet')
    UpdatePoliciesService.new(policies: [@policy_data], network: 'mainnet').call
    assert_nil Policy.find_by(pubkey: 'old_pubkey')
    assert Policy.find_by(pubkey: 'policy_pubkey_1')
  end

  test 'removes PolicyIdentity for missing identities' do
    policy = create(:policy, pubkey: 'policy_pubkey_1', network: 'mainnet')
    identity1 = create(:validator, account: 'acc1')
    identity2 = create(:validator, account: 'acc2')
    PolicyIdentity.create!(policy: policy, validator: identity1, account: identity1.account)
    PolicyIdentity.create!(policy: policy, validator: identity2, account: identity2.account)
    data = @policy_data.deep_dup
    data['data']['identities'] = [identity1.account]
    UpdatePoliciesService.new(policies: [data], network: 'mainnet').call
    assert_equal [identity1.account], policy.reload.policy_identities.pluck(:account)
  end

  test 'handles missing token_metadata gracefully' do
    data = @policy_data.deep_dup
    data.delete('token_metadata')
    UpdatePoliciesService.new(policies: [data], network: 'mainnet').call
    policy = Policy.find_by(pubkey: 'policy_pubkey_1')
    assert_nil policy.name
    assert_nil policy.mint
    assert_nil policy.symbol
    assert_nil policy.additional_metadata
  end
end
