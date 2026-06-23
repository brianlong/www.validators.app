# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

class GdiScoreTest < ActiveSupport::TestCase
  GDI_API_URL = "https://gdindex.app/gdi/leaderboard-latest.json"

  def setup
    @pool1 = create(:stake_pool, name: "BlazeStake", ticker: "bsol", network: "mainnet", gdi_score: nil)
    @pool2 = create(:stake_pool, name: "Jito", ticker: "jitosol", network: "mainnet", gdi_score: nil)
    @pool_testnet = create(:stake_pool, name: "Jpool", ticker: "jsol", network: "testnet", gdi_score: nil)
  end

  def gdi_response(pools)
    {
      epoch: 989,
      pools: pools
    }.to_json
  end

  test "script updates gdi_score for mainnet pools" do
    stub_request(:get, GDI_API_URL)
      .to_return(
        status: 200,
        body: gdi_response([
          { pool_name: "bSOL", gdi: 3.898 },
          { pool_name: "JitoSOL", gdi: 3.558 }
        ]),
        headers: { 'Content-Type' => 'application/json' }
      )

    load(Rails.root.join("script", "gdi_score.rb"))

    assert_in_delta 3.898, @pool1.reload.gdi_score, 0.001
    assert_in_delta 3.558, @pool2.reload.gdi_score, 0.001
  end

  test "script does not update testnet pools" do
    stub_request(:get, GDI_API_URL)
      .to_return(
        status: 200,
        body: gdi_response([{ pool_name: "JSOL", gdi: 3.9 }]),
        headers: { 'Content-Type' => 'application/json' }
      )

    load(Rails.root.join("script", "gdi_score.rb"))

    assert_nil @pool_testnet.reload.gdi_score
  end

  test "script matches pool_name case-insensitively via ticker" do
    stub_request(:get, GDI_API_URL)
      .to_return(
        status: 200,
        body: gdi_response([{ pool_name: "BSOL", gdi: 3.898 }]),
        headers: { 'Content-Type' => 'application/json' }
      )

    load(Rails.root.join("script", "gdi_score.rb"))

    assert_in_delta 3.898, @pool1.reload.gdi_score, 0.001
  end

  test "script skips pools not present in GDI response" do
    stub_request(:get, GDI_API_URL)
      .to_return(
        status: 200,
        body: gdi_response([{ pool_name: "bSOL", gdi: 3.898 }]),
        headers: { 'Content-Type' => 'application/json' }
      )

    load(Rails.root.join("script", "gdi_score.rb"))

    assert_in_delta 3.898, @pool1.reload.gdi_score, 0.001
    assert_nil @pool2.reload.gdi_score
  end

  test "script handles API failure with retry" do
    call_count = 0
    stub_request(:get, GDI_API_URL)
      .to_return do |_request|
        call_count += 1
        if call_count <= 3
          { status: 500, body: "", headers: {} }
        else
          {
            status: 200,
            body: gdi_response([{ pool_name: "bSOL", gdi: 3.898 }]),
            headers: { 'Content-Type' => 'application/json' }
          }
        end
      end

    Object.send(:remove_const, :SLEEP_TIME) if defined?(SLEEP_TIME)
    Object.const_set(:SLEEP_TIME, 0.01)

    load(Rails.root.join("script", "gdi_score.rb"))

    assert_equal 4, call_count
    assert_in_delta 3.898, @pool1.reload.gdi_score, 0.001
  end

  test "script stops retrying after max attempts" do
    call_count = 0
    stub_request(:get, GDI_API_URL)
      .to_return do |_request|
        call_count += 1
        { status: 500, body: "", headers: {} }
      end

    Object.send(:remove_const, :SLEEP_TIME) if defined?(SLEEP_TIME)
    Object.const_set(:SLEEP_TIME, 0.01)

    assert_nothing_raised do
      load(Rails.root.join("script", "gdi_score.rb"))
    end

    assert_equal 5, call_count
  end
end
