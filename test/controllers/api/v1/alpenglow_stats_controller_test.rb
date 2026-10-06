# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class AlpenglowStatsControllerTest < ActionDispatch::IntegrationTest
      include ResponseHelper

      setup do
        @user = create(:user)
        @network = "alpenglow-community"
        validator = create(:validator, network: @network)
        vote_account = create(:vote_account, validator: validator, network: @network)
        [221, 222].each do |epoch|
          AlpenglowValidatorEpochStat.create!(
            network: @network,
            epoch: epoch,
            vote_account: vote_account,
            validator: validator,
            leader_slots: 100,
            leader_slots_with_final_cert: 90,
            leader_fast_finalized: epoch == 222 ? 20 : 40,
            leader_slow_finalized: 60,
            leader_final_lag_sum: 120,
            last_block_user_agent: "agave/4.3.0 (src:1; feat:2, client:JitoLabs)"
          )
        end
      end

      test "request without token should get error" do
        get api_v1_alpenglow_cluster_stats_url(network: @network)

        assert_response 401
        assert_equal({ "error" => "Unauthorized" }, response_to_json(@response.body))
      end

      test "returns epochs and stats for the latest epoch" do
        get api_v1_alpenglow_cluster_stats_url(network: @network), headers: { "Token" => @user.api_token }

        assert_response 200
        json = response_to_json(@response.body)
        assert_equal [222, 221], json["epochs"]
        assert_equal 222, json["cluster_stats"]["epoch"]
        assert_in_delta 25.0, json["cluster_stats"]["fast_percent"]
        assert_in_delta 1.5, json["cluster_stats"]["average_final_lag"]
        assert_equal "JitoLabs", json["cluster_stats"]["clients"].first["client"]
      end

      test "returns stats for the requested epoch" do
        get api_v1_alpenglow_cluster_stats_url(network: @network, epoch: 221), headers: { "Token" => @user.api_token }

        assert_response 200
        assert_equal 221, response_to_json(@response.body)["cluster_stats"]["epoch"]
      end

      test "returns null stats for networks without data" do
        get api_v1_alpenglow_cluster_stats_url(network: "mainnet"), headers: { "Token" => @user.api_token }

        assert_response 200
        assert_equal({ "epochs" => [], "cluster_stats" => nil }, response_to_json(@response.body))
      end

      test "validators returns validator stats for the latest epoch" do
        get api_v1_alpenglow_validator_stats_url(network: @network), headers: { "Token" => @user.api_token }

        assert_response 200
        json = response_to_json(@response.body)
        assert_equal 222, json["epoch"]
        assert_equal 1, json["total_count"]
        assert_equal "notar_participation", json["sort_by"]
        assert_equal 100, json["validators"].first["leader_slots"]
        assert_equal "JitoLabs", json["validators"].first["client"]
      end

      test "validators accepts epoch, sorting and pagination params" do
        params = { network: @network, epoch: 221, sort_by: "leader_slots", direction: "asc", page: 1, per: 10 }
        get api_v1_alpenglow_validator_stats_url(params), headers: { "Token" => @user.api_token }

        json = response_to_json(@response.body)
        assert_equal [221, "leader_slots", "asc", 10], json.values_at("epoch", "sort_by", "direction", "per")
      end

      test "validators returns empty list for networks without stats" do
        get api_v1_alpenglow_validator_stats_url(network: "mainnet"), headers: { "Token" => @user.api_token }

        assert_equal({ "epoch" => nil, "total_count" => 0, "validators" => [] }, response_to_json(@response.body))
      end

      test "returns error for invalid network" do
        get api_v1_alpenglow_cluster_stats_url(network: "devnet"), headers: { "Token" => @user.api_token }

        assert_response 400
      end
    end
  end
end
