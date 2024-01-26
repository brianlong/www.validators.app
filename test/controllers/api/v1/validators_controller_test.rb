# frozen_string_literal: true

require "test_helper"
require "rack/cors"
require "rack/test"

# ApiControllerTest
class ValidatorsControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper
  include ValidatorsControllerHelper

  def setup
    @user_params = {
      username: "test",
      email: "test@test.com",
      password: "password"
    }
    @user = User.create(@user_params)

    Validator.destroy_all
  end

  test "GET api_v1_validators with token returns only validators from chosen network with scores" do
    create_list(
      :validator,
      3,
      :with_score,
      :with_data_center_through_validator_ip
    )
    create_list(
      :validator,
      3,
      :with_score,
      :mainnet,
      :with_data_center_through_validator_ip
    )

    # Testnet
    get api_v1_validators_url(network: "testnet"),
        headers: { "Token" => @user.api_token }

    json = response_to_json(@response.body)

    assert_response 200
    assert_equal 3, json.size
    assert_equal "testnet", json.first["network"]

    # Mainnet
    get api_v1_validators_url(network: "mainnet"),
        headers: { "Token" => @user.api_token }

    json = response_to_json(@response.body)

    assert_response 200
    assert_equal 3, json.size
    assert_equal "mainnet", json.first["network"]
  end

  test "GET api_v1_validators returns all data" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "Test Account"
    )
    create(:validator_history,
           account: validator.account,
           epoch_credits: 100,
           epoch: 222,
           validator: validator)
    create(:vote_account, validator: validator)
    create(:report, :build_skipped_slot_percent)

    get api_v1_validators_url(network: "testnet"),
        headers: { "Token" => @user.api_token }
    assert_response 200

    json = response_to_json(@response.body)
    validator_with_all_data = json.select { |j| j["account"] == "Test Account" }.first
    validator_active_stake = validator.validator_score_v1.active_stake

    assert_equal 1, json.size

    # Adjust after adding/removing attributes in json builder
    assert_equal 40, validator_with_all_data.keys.size

    # Validator
    assert_equal "testnet", validator_with_all_data["network"]
    assert_equal "john doe", validator_with_all_data["name"]
    assert_equal "johndoe", validator_with_all_data["keybase_id"]
    assert_equal "http://www.avatar_url.com", validator_with_all_data["avatar_url"]

    # Score
    assert_equal 7, validator_with_all_data["total_score"]
    assert_equal 1, validator_with_all_data["root_distance_score"]
    assert_equal 2, validator_with_all_data["vote_distance_score"]
    assert_equal 0, validator_with_all_data["skipped_slot_score"]
    # assert_equal 0, validator_with_all_data["skipped_after_score"]
    assert_equal "1.6.7", validator_with_all_data["software_version"]
    assert_equal 2, validator_with_all_data["software_version_score"]
    assert_equal 0, validator_with_all_data["stake_concentration_score"]
    assert_nil validator_with_all_data["data_center_concentration_score"]
    assert_equal 1, validator_with_all_data["published_information_score"]
    assert_equal 1, validator_with_all_data["security_report_score"]
    assert_equal 0, validator_with_all_data["consensus_mods_score"]
    assert_equal validator_active_stake, validator_with_all_data["active_stake"]
    assert_equal 10, validator_with_all_data["commission"]
    assert_equal false, validator_with_all_data["delinquent"]
    assert_equal validator.data_center_host.host, validator_with_all_data["data_center_host"]
    assert_nil validator_with_all_data["admin_warning"]
    assert validator_with_all_data["is_active"]

    # Vote accounts
    assert_equal "Test Account", validator_with_all_data["vote_account"]

    # Report
    assert_equal "skipped_slots", validator_with_all_data["skipped_slots"]
    assert_equal "skipped_slot_percent", validator_with_all_data["skipped_slot_percent"]
    assert_nil validator_with_all_data["ping_time"]

    # Data Center
    assert_equal 12345, validator_with_all_data["autonomous_system_number"]
    assert_equal "51.2993", validator_with_all_data["latitude"]
    assert_equal "9.491", validator_with_all_data["longitude"]
    assert_equal "12345-DE-Berlin", validator_with_all_data["data_center_key"]


    # Validator history
    assert_equal 100, validator_with_all_data["epoch_credits"]

    # Epoch
    assert_equal 222, validator_with_all_data["epoch"]
  end

  test "GET api_v1_validators with admin_warning returns correct data" do
    validator = create(
      :validator,
      :with_score,
      :with_admin_warning,
      :with_data_center_through_validator_ip,
      account: "Test Account",
    )

    get api_v1_validators_url(network: "testnet"),
        headers: { "Token" => @user.api_token }
    assert_response 200

    json = response_to_json(@response.body)
    validator_with_all_data = json.select { |j| j["account"] == "Test Account" }.first

    assert_equal 0, validator_with_all_data["total_score"]
    assert_equal "test warning", validator_with_all_data["admin_warning"]
  end

  test "GET api_v1_validators with token and search query returns correct data" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "Test Account"
    )

    search_query = "john doe"

    get api_v1_validators_url(network: "testnet", q: search_query),
        headers: { "Token" => @user.api_token }
    assert_response 200

    json = response_to_json(@response.body)

    assert_equal 1, json.size
    assert_equal search_query, json.first["name"]
  end

  test "GET api_v1_validators with token and not existing search query returns no data" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "Test Account"
    )

    search_query = "4321"

    get api_v1_validators_url(network: "testnet", q: search_query),
        headers: { "Token" => @user.api_token }
    assert_response 200

    json = response_to_json(@response.body)
    assert_equal 0, json.size
  end

  test "GET api_v1_validators with token, limit and page passed in returns limited data" do
    create_list(
      :validator,
      10,
      :with_score,
      :with_data_center_through_validator_ip
    )

    limit = 5
    page = 2

    get api_v1_validators_url(network: "testnet", limit: limit, page: page),
        headers: { "Token" => @user.api_token }

    assert_response 200
    json = response_to_json(@response.body)

    assert_equal 5, json.size
  end

  test "GET api_v1_validators with token and limit passed in returns limited data" do
    create_list(
      :validator,
      10,
      :with_score,
      :with_data_center_through_validator_ip
    )
    limit = 5

    get api_v1_validators_url(network: "testnet", limit: limit),
        headers: { "Token" => @user.api_token }

    assert_response 200
    json = response_to_json(@response.body)

    assert_equal limit, json.size
  end

  test "GET api_v1_validators with token and page passed in returns limited data" do
    create_list(
      :validator,
      60,
      :with_score,
      :with_data_center_through_validator_ip
    )
    page = 1

    get api_v1_validators_url(network: "testnet", page: page),
        headers: { "Token" => @user.api_token }

    assert_response 200
    json = response_to_json(@response.body)

    # Default limit is 9999
    assert_equal Validator.count, json.size
  end

  test "GET api_v1_validators with token and page passed returns no data when offset is above number of records" do
    create_list(
      :validator,
      10,
      :with_score,
      :with_data_center_through_validator_ip
    )
    page = 2

    get api_v1_validators_url(network: "testnet", page: page),
        headers: { "Token" => @user.api_token }

    assert_response 200
    json = response_to_json(@response.body)

    # Default limit is 9999, so the offset is above number of records.
    assert_equal 0, json.size
  end

  test "GET api_v1_validators with token but without page and limit returns all data" do
    create_list(
      :validator,
      10,
      :with_score,
      :with_data_center_through_validator_ip
    )

    get api_v1_validators_url(network: "testnet"),
        headers: { "Token" => @user.api_token }

    assert_response 200
    json = response_to_json(@response.body)

    assert_equal Validator.all.size, json.size
  end
  #
  # Pagination with search
  #
  test "GET api_v1_validators with token, search query, limit and page passed returns limited data" do
    create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      name: "search_query"
    )
    create_list(
      :validator,
      5,
      :with_score,
      :with_data_center_through_validator_ip
    )

    limit = 5
    page = 1
    search_query = "search_query"

    get api_v1_validators_url(network: "testnet", limit: limit, page: page, q: search_query),
        headers: { "Token" => @user.api_token }

    assert_response 200
    json = response_to_json(@response.body)

    assert_equal 1, json.size
    assert_equal search_query, json.first["name"]
  end

  test "GET api_v1_validators includes validator without data_center assigned" do
    v = create(
      :validator,
      :with_score,
      name: "I do not have data_center assigned"
    )

    get api_v1_validators_url(network: "testnet"),
        headers: { "Token" => @user.api_token }

    assert_response 200
    json = response_to_json(@response.body)

    assert_equal 1, json.size
    assert_nil v.data_center
    assert_equal v.name, json.first["name"]
  end

  test "GET api_v1_validator with token returns all data" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "Test Account"
    )
    create(:validator_history,
           account: validator.account,
           epoch_credits: 100,
           epoch: 222,
           validator: validator)
    create(:vote_account, validator: validator)
    create(:report, :build_skipped_slot_percent)

    get api_v1_validator_url(
      network: "testnet",
      account: validator.account
    ), headers: { "Token" => @user.api_token }

    assert_response 200

    json_response = response_to_json(@response.body)
    validator_active_stake = validator.validator_score_v1.active_stake

    # Adjust after adding/removing attributes in json builder
    assert_equal 40, json_response.keys.size

    # Validator
    assert_equal "testnet", json_response["network"]
    assert_equal "john doe", json_response["name"]
    assert_equal "johndoe", json_response["keybase_id"]
    assert_equal "http://www.avatar_url.com", json_response["avatar_url"]

    # Score
    assert_equal 7, json_response["total_score"]
    assert_equal 1, json_response["root_distance_score"]
    assert_equal 2, json_response["vote_distance_score"]
    assert_equal 0, json_response["skipped_slot_score"]
    assert_equal "1.6.7", json_response["software_version"]
    assert_equal 2, json_response["software_version_score"]
    assert_equal 0, json_response["stake_concentration_score"]
    assert_nil json_response["data_center_concentration_score"]
    assert_equal 1, json_response["published_information_score"]
    assert_equal 1, json_response["security_report_score"]
    assert_equal 0, json_response["consensus_mods_score"]
    assert_equal validator_active_stake, json_response["active_stake"]
    assert_equal 10, json_response["commission"]
    assert_equal false, json_response["delinquent"]
    assert_equal validator.data_center_host.host, json_response["data_center_host"]

    # Vote accounts
    assert_equal "Test Account", json_response["vote_account"]

    # Report
    assert_equal "skipped_slots", json_response["skipped_slots"]
    assert_equal "skipped_slot_percent", json_response["skipped_slot_percent"]
    assert_nil json_response["ping_time"]

    # Data Center
    assert_equal 12345, json_response["autonomous_system_number"]
    assert_equal "51.2993", json_response["latitude"]
    assert_equal "9.491", json_response["longitude"]
    assert_equal "12345-DE-Berlin", json_response["data_center_key"]

    # Validator history
    assert_equal 100, json_response["epoch_credits"]

    # Epoch
    assert_equal 222, json_response["epoch"]
  end

  test "GET api_v1_validator with internal param returns all data" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "Test Account"
    )
    create(:validator_history,
           account: validator.account,
           epoch_credits: 100,
           epoch: 222,
           validator: validator)
    create(:vote_account, validator: validator)
    create(:report, :build_skipped_slot_percent)

    get api_v1_validator_url(
      network: "testnet",
      account: validator.account,
      internal: true
    ),
        headers: { "Token" => @user.api_token }
    assert_response 200

    json = JSON.parse @response.body
    validator_json = JSON.parse json["validator"]
    vote_account_json = validator_json["vote_account_active"]
    score_json = JSON.parse json["score"]
    validator_history_json = json["validator_history"]

    validator_json.each do |k, v|
      next if %w[id created_at updated_at vote_account_active].include? k
      if validator.send(k).nil?
        assert_nil v
      else
        assert_equal v, validator.send(k)
      end
    end

    vote_account_json.each do |k, v|
      next if %w[created_at updated_at].include? k
      if validator.vote_account_active.send(k).nil?
        assert_nil v
      else
        assert_equal v, validator.vote_account_active.send(k)
      end
    end

    score_json.each do |k, v|
      next if %w[created_at updated_at stake_concentration].include? k
      if validator.score.send(k).nil?
        assert_nil v
      else
        assert_equal v, validator.score.send(k)
      end
    end

    assert_equal score_json["stake_concentration"].to_f, validator.score.stake_concentration

    validator_history_json.each do |k, v|
      next if %w[created_at updated_at].include? k
      if validator.validator_history_last.send(k).nil?
        assert_nil v
      else
        assert_equal v, validator.validator_history_last.send(k)
      end
    end
    # assert_equal validator.account, validator_json["account"]
    # assert_equal validator.name, validator_json["name"]
    # assert_equal
  end

  test "GET api_v1_validator with token and with_history=true returns all data with history fields" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "Test Account"
    )
    create(:validator_history,
           account: validator.account,
           epoch_credits: 100,
           epoch: 222,
           validator: validator)
    create(:vote_account, validator: validator)
    create(:report, :build_skipped_slot_percent)

    get api_v1_validator_url(
      network: "testnet",
      account: validator.account
    ), headers: { "Token" => @user.api_token },
    params: { with_history: true }

    assert_response 200

    json_response = response_to_json(@response.body)
    validator_active_stake = validator.validator_score_v1.active_stake

    # Adjust after adding/removing attributes in json builder
    assert_equal 48, json_response.keys.size

    # Score
    assert_equal [1, 2, 3, 4, 5], json_response["root_distance_history"]
    assert_equal [5, 4, 3, 2, 1], json_response["vote_distance_history"]
    assert_equal [0.123], json_response["skipped_after_history"]
    assert_equal [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1], json_response["skipped_slot_history"]
    assert_equal [0.2051], json_response["skipped_slot_moving_average_history"]
    assert_equal [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9], json_response["skipped_vote_history"]
    assert_equal "0.001", json_response["stake_concentration"]
    assert_equal "1.6.7", json_response["software_version"]
  end

  test "GET api_v1_validator with token and with empty or other than true param with_history does NOT include history" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "Test Account"
    )
    create(:validator_history,
           account: validator.account,
           epoch_credits: 100,
           epoch: 222,
           validator: validator)
    create(:vote_account, validator: validator)
    create(:report, :build_skipped_slot_percent)

    required_params = { network: "testnet", account: validator.account }

    ### with_history: nil
    get api_v1_validator_url(required_params),
      headers: { "Token" => @user.api_token },
      params: { with_history: nil }

    json_response = response_to_json(@response.body)

    ValidatorScoreV1::HISTORY_FIELDS.each do |field|
      assert_nil json_response[field.to_s]
    end

    ### with_history: integer different than 1
    get api_v1_validator_url(required_params),
      headers: { "Token" => @user.api_token },
      params: { with_history: 2 }

    json_response = response_to_json(@response.body)

    ValidatorScoreV1::HISTORY_FIELDS.each do |field|
      assert_nil json_response[field.to_s]
    end

    ### with_history: random string
    get api_v1_validator_url(required_params),
      headers: { "Token" => @user.api_token },
      params: { with_history: "string" }

    json_response = response_to_json(@response.body)

    ValidatorScoreV1::HISTORY_FIELDS.each do |field|
      assert_nil json_response[field.to_s]
    end
  end

  test "GET api_v1_validator with token returns ValidatorNotFound when wrong account provided" do
    get api_v1_validator_url(
      network: "testnet",
      account: "Wrong account"
    ), headers: { "Token" => @user.api_token }

    json_response = response_to_json(@response.body)
    expected_response = { "status" => "Validator Not Found" }

    assert_response 404
    assert_equal expected_response, json_response
  end

  test "GET api_v1_validator as csv with token returns correct results" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      account: "Test Account"
    )

    path = api_v1_validator_url(
      network: "testnet",
      account: validator.account
    ) + ".csv"

    get path, headers: { "Token" => @user.api_token }

    assert_response :success
    assert_equal "text/csv", response.content_type
    csv = CSV.parse response.body # Let raise if invalid CSV
    assert csv
    assert_equal csv.size, 2

    headers = index_csv_headers(nil)
    assert_equal csv.first, headers
  end

  test "GET api_v1_validators as csv with token returns correct results" do
    create_list(
      :validator,
      10,
      :with_score,
      :with_data_center_through_validator_ip
    )

    path = api_v1_validators_url(network: "testnet") + ".csv"

    get path, headers: { "Token" => @user.api_token }

    assert_response :success
    assert_equal "text/csv", response.content_type
    csv = CSV.parse response.body # Let raise if invalid CSV
    assert csv
    assert_equal csv.size, 11

    headers = index_csv_headers(nil)
    assert_equal csv.first, headers
  end

  test "GET api_v1_validators_ledger returns correct data" do
    validator = create(
      :validator,
      :with_score,
      account: "Test Account"
    )

    get api_v1_validator_ledger_path(network: "testnet", account: "Test Account"),
      headers: { "Token" => @user.api_token }
    assert_response 200

    expected_response = {
      active_stake: validator.active_stake,
      commission: validator.commission,
      total_score: validator.score.displayed_total_score,
      vote_account: validator.vote_account_active&.account,
      name: validator.name,
      avatar_url: validator.avatar_url,
      www_url: validator.www_url
    }.map { |k, v| [k.to_s, v] }.to_h

    json = response_to_json(@response.body)

    assert_equal json, expected_response
  end

  test "GET api_v1_validators_ledger returns correct data even if there is no score attached" do
    validator = create(
      :validator,
      account: "Test Account"
    )

    get api_v1_validator_ledger_path(network: "testnet", account: "Test Account"),
      headers: { "Token" => @user.api_token }
    assert_response 200

    expected_response = {
      active_stake: validator.active_stake,
      commission: validator.commission,
      total_score: nil,
      vote_account: validator.vote_account_active&.account,
      name: validator.name,
      avatar_url: validator.avatar_url,
      www_url: validator.www_url
    }.map { |k, v| [k.to_s, v] }.to_h

    json = response_to_json(@response.body)

    assert_equal json, expected_response
  end

  test "GET api_v1_validators_ledger returns 404 if no validator found" do
    get api_v1_validator_ledger_path(network: "testnet", account: "zzz"),
      headers: { "Token" => @user.api_token }

    assert_response 404

    json = response_to_json(@response.body)
    assert_equal json, { "status"=>"Validator Not Found" }
  end
end
