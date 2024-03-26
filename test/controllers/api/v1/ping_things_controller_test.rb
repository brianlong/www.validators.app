# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class PingThingsControllerTest < ActionDispatch::IntegrationTest
      include ResponseHelper

      def setup
        @user = create(:user)
        @params_sample = {
          amount: "1",
          application: "mango",
          commitment_level: "finalized",
          signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
          success: "true",
          time: "234",
          transaction_type: "transfer"
        }
        @headers = { "Token" => @user.api_token }
      end

      test "POST api_v1_ping_thing without token returns error" do
        post api_v1_ping_thing_path(network: "testnet")
        assert_response 401
        expected_response = { "error" => "Unauthorized" }

        assert_equal expected_response, response_to_json(@response.body)
      end

      test "POST api_v1_ping_thing with token returns 200 and saves the data" do
        post api_v1_ping_thing_path(
          network: "testnet"
        ), headers: @headers, params: @params_sample
        assert_response 201
        expected_response = { "status" => "created" }

        assert_equal expected_response, response_to_json(@response.body)
        assert_equal @params_sample, JSON.parse(PingThingRaw.last.raw_data).symbolize_keys
      end

      test "POST api_v1_ping_thing with wrong data length returns 400 error" do
        post api_v1_ping_thing_path(
          network: "testnet"
        ), headers: @headers, params: {}
        assert_response 400
        expected_response = {"base"=>["Provided data length is not valid"]}

        assert_equal expected_response, response_to_json(@response.body)
      end

      test "POST api_v1_ping_thing_batch_path without token returns error" do
        post api_v1_ping_thing_batch_path(network: "testnet")
        assert_response 401
        expected_response = { "error" => "Unauthorized" }

        assert_equal expected_response, response_to_json(@response.body)
      end

      test "POST api_v1_ping_thing_batch_path with token should return 200 and save the data" do
        params_batch = {
          transactions: [
            @params_sample, @params_sample
          ]
        }

        post api_v1_ping_thing_batch_path(
          network: "testnet"
        ), headers: @headers, params: params_batch
        assert_response 201
        expected_response = { "status" => "created" }

        assert_equal expected_response, response_to_json(@response.body)
        assert_equal params_batch[:transactions].last, JSON.parse(PingThingRaw.last.raw_data).symbolize_keys
      end

      test "POST api_v1_ping_thing_batch_path with token should return 400 when there's too much data" do
        transactions = []
        1001.times {transactions.push(@params_sample)}
        params_batch = {
          transactions: transactions
        }

        post api_v1_ping_thing_batch_path(
          network: "testnet"
        ), headers: @headers, params: params_batch
        assert_response 400
        expected_response = "Number of records exceeds 1000"

        assert_equal expected_response, response_to_json(@response.body)
      end

      test "GET api_v1_ping_things with correct network returns pings from chosen network" do
        ping_thing_time = create(:ping_thing, :testnet, :processed)
        create(:ping_thing, :mainnet)

        get api_v1_ping_things_path(network: "testnet"), headers: @headers

        assert_response 200

        json = response_to_json(@response.body)
        json_record = json.first
        signature = "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s"

        assert_equal 1, json.size
        assert_equal 12, json_record.size

        assert_equal "Mango",                         json_record["application"]
        assert_equal "processed",                     json_record["commitment_level"]
        assert                                        json_record["created_at"]
        assert_equal "testnet",                       json_record["network"]
        assert_equal 1,                               json_record["response_time"]
        assert_equal signature,                       json_record["signature"]
        assert_equal true,                            json_record["success"]
        assert_equal "transfer",                      json_record["transaction_type"]
        assert_equal ping_thing_time.user.username,   json_record["username"]
        assert_equal 123,                             json_record["slot_sent"]
        assert_equal 125,                             json_record["slot_landed"]
      end

      test "GET api_v1_ping_things with limit present returns pings for chosen limit" do
        3.times do
          create(:ping_thing, :testnet)
        end

        get api_v1_ping_things_path(network: "testnet", limit: 2), headers: @headers

        assert_response 200
        assert_equal 2, response_to_json(@response.body).size
      end

      test "GET api_v1_ping_things with limit returns correct pings starting from the newest reported_at" do
        create(:ping_thing, :testnet, reported_at: 2.days.ago, response_time: 123)
        create(:ping_thing, :testnet, reported_at: 1.day.ago, response_time: 321)

        get api_v1_ping_things_path(network: "testnet", limit: 1), headers: @headers

        json = response_to_json(@response.body)
        assert_equal 321, json.first["response_time"]
      end

      test "GET api_v1_ping_things without page present returns the first page" do
        3.times do
          create(:ping_thing, :testnet)
        end

        get api_v1_ping_things_path(network: "testnet", limit: 2), headers: @headers

        assert_response 200
        assert_equal 2, response_to_json(@response.body).size
      end

      test "GET api_v1_ping_things with page param, returns correct pings starting from the newest reported_at" do
        create(:ping_thing, :testnet, reported_at: 3.days.ago, response_time: 123)
        create(:ping_thing, :testnet, reported_at: 2.days.ago, response_time: 456)
        create(:ping_thing, :testnet, reported_at: 1.day.ago, response_time: 789)

        get api_v1_ping_things_path(network: "testnet", limit: 1, page: 1), headers: @headers

        json = response_to_json(@response.body)
        assert_equal 789, json.first["response_time"]
        assert_equal 1, response_to_json(@response.body).size

        get api_v1_ping_things_path(network: "testnet", limit: 1, page: 2), headers: @headers

        json = response_to_json(@response.body)
        assert_equal 456, json.first["response_time"]

        get api_v1_ping_things_path(network: "testnet", limit: 1, page: 3), headers: @headers

        json = response_to_json(@response.body)
        assert_equal 123, json.first["response_time"]
      end

      test "GET api_v1_ping_things does not return total_count for invalid of false param" do
        4.times do
          create(:ping_thing, :testnet)
        end

        get api_v1_ping_things_path(network: "testnet", with_stats: "asd"), headers: @headers

        assert_equal 4, response_to_json(@response.body).size

        get api_v1_ping_things_path(network: "testnet", with_stats: "false"), headers: @headers

        assert_equal 4, response_to_json(@response.body).size

        get api_v1_ping_things_path(network: "testnet", with_stats: 1), headers: @headers

        assert_equal 4, response_to_json(@response.body).size
      end

      test "GET api_v1_ping_things with filter params returns filtered records" do
        10.times do |n|
          create(:ping_thing, :testnet, response_time: n, success: true)
        end

        filter = 5
        user = PingThing.last.user.username

        get api_v1_ping_things_path(network: "testnet", time_filter: filter), headers: @headers
        json_response = response_to_json(@response.body)
        assert_equal 5, json_response.size
        assert_equal [], json_response.select{ |pt| pt["response_time"].to_i < filter }

        PingThing.where(network: "testnet").update_all(success: false)
        get api_v1_ping_things_path(network: "testnet", success: false), headers: @headers
        assert_equal 10, response_to_json(@response.body).size

        PingThing.where(network: "testnet").first.update(success: true)
        PingThing.where(network: "testnet").last.update(success: true)
        assert_equal 2, PingThing.where(network: "testnet", success: true).count
        get api_v1_ping_things_path(network: "testnet", success: true, time_filter: filter), headers: @headers
        assert_equal 1, response_to_json(@response.body).size
      end

      test "GET api_v1_ping_things with posted_by filter returns filtered records" do
        users = [
          create(:user, :ping_thing_user, username: "username.fake"),
          create(:user, :ping_thing_user, username: "username.fake.2"),
          create(:user, :ping_thing_user, username: "fake.username.fake"),
          create(:user, :ping_thing_user, username: "username.fake.fake")
        ]

        users.each { |u| create(:ping_thing, :testnet, user: u) }

        get api_v1_ping_things_path(
          network: "testnet", posted_by: "username.fake"
        ), headers: @headers
        assert_equal 3, response_to_json(@response.body).size
        assert_equal ["username.fake", "username.fake.2", "username.fake.fake"],
          response_to_json(@response.body).map { |ping| ping["username"] }.sort
      end

      test "GET api_v1_ping_things as csv returns success" do
        10.times do |n|
          create(:ping_thing, :testnet, response_time: n)
        end

        path = api_v1_ping_things_path(network: "testnet") + ".csv"
        get path, headers: @headers

        assert_response :success
        assert_equal "text/csv", response.content_type
        csv = CSV.parse response.body # Let raise if invalid CSV
        assert csv
        assert_equal csv.size, 11

        headers = (
          PingThing::API_FIELDS +
          PingThing::API_USER_FIELDS
        ).map(&:to_s)
        assert_equal csv.first, headers
      end
    end
  end
end
