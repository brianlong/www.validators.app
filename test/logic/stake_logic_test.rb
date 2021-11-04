require 'test_helper'

# StakeLogicTest
class StakeLogicTest < ActiveSupport::TestCase
  include StakeLogic

  def setup
    @testnet_url = 'https://api.testnet.solana.com'
    @mainnet_url = 'https://api.mainnet-beta.solana.com'

    create(:batch, network: 'testnet', gathered_at: DateTime.now, scored_at: DateTime.now)

    # Create our initial payload with the input values
    @initial_payload = {
      # config_urls: Rails.application.credentials.solana[:testnet_urls],
      config_urls: [
        @testnet_url
      ],
      network: 'testnet'
    }
  end

  test 'get_last_batch' do
    p = Pipeline.new(200, @initial_payload)
                .then(&get_last_batch)
    assert_not_nil p[:payload][:batch]
    assert p[:payload][:batch].uuid.include?('-')
  end

  test 'get_stake_accounts' do
    json_data = File.read("#{Rails.root}/test/json/stake_accounts.json")

    SolanaCliService.stub(:request, json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)

      assert_not_nil p[:payload][:stake_accounts]
      assert_equal 57_511, p[:payload][:stake_accounts].count
    end
  end
end
