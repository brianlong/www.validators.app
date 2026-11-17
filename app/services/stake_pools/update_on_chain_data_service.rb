# frozen_string_literal: true

module StakePools
  class UpdateOnChainDataService
    include SolanaRequestsLogic

    STAKE_POOL_PROGRAMS = %w[
      SPoo1Ku8WFXoNDMHPsrGSTSG1Y47rzgn41SLUNakuHy
      SP12tWFxD9oJsVWNavTTBZvMbA6gkAmxtVgxdqvyvhY
      SPMBzsVUuoHA4Jm6KunbsotaahvVikZs1JyTW6iJvbn
    ].freeze
    MAX_ACCOUNTS_PER_REQUEST = 100

    def initialize(network:, config_urls:)
      @network = network
      @config_urls = config_urls
    end

    def call
      StakePool.where(network: @network).where.not(pool_address: [nil, ""]).each_slice(MAX_ACCOUNTS_PER_REQUEST) do |pools|
        accounts = fetch_accounts(pools.map(&:pool_address))
        next if accounts.nil?

        pools.zip(accounts).each { |pool, account| update_pool(pool, account) }
      end
    end

    private

    def fetch_accounts(addresses)
      response = solana_client_request(
        @config_urls,
        :get_multiple_accounts,
        params: [addresses, { encoding: "base64" }]
      )

      response.is_a?(Hash) ? response["value"] : nil
    end

    def update_pool(pool, account)
      if account.blank? || !STAKE_POOL_PROGRAMS.include?(account["owner"])
        Rails.logger.error("Stake pool account not found or invalid: #{pool.name} (#{pool.pool_address})")
        return
      end

      pool.update!(AccountParser.new(account["data"].first).call)
    rescue AccountParser::InvalidAccount, ActiveRecord::ActiveRecordError => e
      Appsignal.send_error(e) if Rails.env.in?(%w[stage production])
      Rails.logger.error("Stake pool #{pool.name} update failed: #{e.message}")
    end
  end
end
