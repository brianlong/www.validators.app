# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

class IbrlScoreTest < ActiveSupport::TestCase
  def setup
    @network = "mainnet"
    @validator1 = create(:validator, account: "kREnNfJrPEHbrjSQDxmxZdGmN6hi7ewXZ3UZTURshrk", network: @network)
    @validator2 = create(:validator, account: "DupN8puwoPdFo9EYm8AXemEn9cMsore1QmZzfPaxyUG4", network: @network)
    
    @score1 = create(:validator_score_v1, validator: @validator1, ibrl_score: nil)
    @score2 = create(:validator_score_v1, validator: @validator2, ibrl_score: nil)

    # Set ARGV to control network in script
    ARGV[0] = @network
  end

  test "script updates ibrl_score for validators" do

    VCR.use_cassette("ibrl_score_success") do
      load(Rails.root.join("script", "ibrl_score.rb"))
    end

    @score1.reload
    @score2.reload

    assert_not_nil @score1.ibrl_score, "Expected validator1's score to be updated"
    assert_equal 99.3672, @score1.ibrl_score
    assert_not_nil @score2.ibrl_score, "Expected validator2's score to be updated"
    assert_equal 99.0665, @score2.ibrl_score
  end

  test "script updates only validators from specified network" do
    # Create testnet validator with same account
    validator_testnet = create(:validator, account: "kREnNfJrPEHbrjSQDxmxZdGmN6hi7ewXZ3UZTURshrk", network: "testnet")
    score_testnet = create(:validator_score_v1, validator: validator_testnet, ibrl_score: nil)

    VCR.use_cassette("ibrl_score_success") do
      load(Rails.root.join("script", "ibrl_score.rb"))
    end

    # mainnet validator should be updated
    assert_not_nil @score1.reload.ibrl_score
    
    # testnet validator with same account should not be updated
    assert_nil score_testnet.reload.ibrl_score
  end

  test "script filters out validators with zero ibrl_score" do
    validator1 = create(:validator, account: "validator_with_zero", network: "mainnet")
    score1 = create(:validator_score_v1, validator: validator1, ibrl_score: nil)
    
    stub_request(:get, "https://explorer.bam.dev/api/v1/ibrl_validators")
      .to_return(
        status: 200,
        body: {
          data: [
            { identity: "validator_with_zero", ibrl_score: 0 },
            { identity: "validator_with_score", ibrl_score: 95.5 }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    load(Rails.root.join("script", "ibrl_score.rb"))
    
    # Validator with zero score should not be updated
    assert_nil score1.reload.ibrl_score
  end

  test "script handles empty data gracefully" do
    stub_request(:get, "https://explorer.bam.dev/api/v1/ibrl_validators")
      .to_return(
        status: 200,
        body: {
          data: [
            { identity: "unknown1", ibrl_score: 0 },
            { identity: "unknown2", ibrl_score: 0 }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Script should raise when no validators match after filtering zeros
    exception = assert_raises(RuntimeError) do
      load(Rails.root.join("script", "ibrl_score.rb"))
    end
    
    assert_match(/No validators with non-zero ibrl_score found/, exception.message)
  end

  test "script handles API failure with retry" do
    validator1 = create(:validator, account: "test_validator", network: "mainnet")
    score1 = create(:validator_score_v1, validator: validator1, ibrl_score: nil)
    
    # First 3 requests fail, 4th succeeds
    call_count = 0
    stub_request(:get, "https://explorer.bam.dev/api/v1/ibrl_validators")
      .to_return do |request|
        call_count += 1
        if call_count <= 3
          { status: 500, body: "", headers: {} }
        else
          { 
            status: 200,
            body: {
              data: [
                { identity: "test_validator", ibrl_score: 95.5 }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          }
        end
      end

    # Override SLEEP_TIME before loading script
    Object.send(:remove_const, :SLEEP_TIME) if defined?(SLEEP_TIME)
    Object.const_set(:SLEEP_TIME, 0.01)
    
    load(Rails.root.join("script", "ibrl_score.rb"))

    # Should have made 4 requests (3 failures + 1 success)
    assert_equal 4, call_count
    # Validator should be updated after retries
    assert_not_nil score1.reload.ibrl_score
    assert_equal 95.5, score1.ibrl_score
  end

  test "script stops retrying after max attempts" do
    # All requests fail
    call_count = 0
    stub_request(:get, "https://explorer.bam.dev/api/v1/ibrl_validators")
      .to_return do |request|
        call_count += 1
        { status: 500, body: "", headers: {} }
      end

    # Override SLEEP_TIME before loading script
    Object.send(:remove_const, :SLEEP_TIME) if defined?(SLEEP_TIME)
    Object.const_set(:SLEEP_TIME, 0.01)

    # Script should not raise after exhausting retries
    assert_nothing_raised do
      load(Rails.root.join("script", "ibrl_score.rb"))
    end

    # Should have made RETRY_MAX (5) requests
    assert_equal 5, call_count
  end
end
