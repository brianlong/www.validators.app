# frozen_string_literal: true

require 'test_helper'

class SolanaRequestsLogicTest < ActiveSupport::TestCase
  include SolanaRequestsLogic

  def setup
    @testnet_url = 'https://api.testnet.solana.com'
    @mainnet_url = 'https://api.mainnet-beta.solana.com'
    @local_url = 'http://127.0.0.1:8899'
  end

  # This test assumes that there is no validator RPC running locally.
  # 159.89.252.85 is my testnet server.
  test 'cli_request with fail over' do
    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', @testnet_url]) do
      rpc_urls = [@local_url, @testnet_url]
      cli_response = cli_request('validators', rpc_urls)

      assert_equal 5, cli_response.count
    end
  end

  # This test assumes that there is no validator RPC running locally.
  test 'cli_request should get first attempt with no fail over' do
    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', @testnet_url]) do
      rpc_urls = [@testnet_url, @local_url]
      cli_response = cli_request('validators', rpc_urls)

      assert_equal 5, cli_response.count
    end
  end

  test 'solana_client_request returns data found in first cluster' do
    clusters = [
      @mainnet_url,
      @testnet_url
    ]

    method = :get_epoch_info

    VCR.use_cassette('solana_client_request') do
      result = solana_client_request(clusters, method)
      assert_equal result["epoch"], 202
    end
  end


  test 'solana_client_request returns data even if one of the clusters is incorrect' do
    clusters = [
      @local_url,
      @testnet_url
    ]

    method = :get_epoch_info

    VCR.use_cassette('solana_client_request incorrect cluster') do
      result = solana_client_request(clusters, method)
      assert_equal result["epoch"], 209
    end
  end

  test 'solana_client_request returns data with optional params' do
    clusters = [
      @mainnet_url
    ]

    method = :get_program_accounts
    config_program_pubkey = 'Config1111111111111111111111111111111111111'
    params = [config_program_pubkey, { encoding: 'jsonParsed' }]

    VCR.use_cassette('solana_client_request optional params') do
      result = solana_client_request(clusters, method, params: params)
      assert_equal 863, result.size
    end
  end
end
