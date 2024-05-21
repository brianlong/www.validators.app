# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'uri'
require 'net/http'

uri = URI("https://kobe.mainnet.jito.network/api/v1/validators")
response = Net::HTTP.get_response(uri)

logger = Logger.new('log/update_jito_validators.log')
logger.info("Fetching Jito validators...")
if response.is_a?(Net::HTTPSuccess)
  json_response = JSON.parse(response.body)
  jito_vote_accounts = json_response["validators"].map do |jito_validator|
    { jito_validator["vote_account"] => jito_validator["mev_commission_bps"] } if jito_validator["running_jito"]
  end.inject(:merge)

  jito_db_validators = Validator.joins(:vote_accounts)
                                .where(
                                  "validators.network = ?
                                   AND vote_accounts.account IN (?)
                                   AND vote_accounts.is_active = TRUE",
                                  "mainnet",
                                  jito_vote_accounts.keys
                                )

  jito_db_validators.each do |validator|
    validator.update(
      jito_commission: jito_vote_accounts[validator.vote_account_active.account],
      jito: true
    )
    logger.info("Updated: #{validator.account}; commission: #{jito_vote_accounts[validator.vote_account_active.account]}")
  end

  Validator.where.not(id: jito_db_validators.pluck(:id)).update_all(jito: false)
  logger.info("Jito validators updated successfully")
else
  logger.error("Failed to fetch Jito validators: #{response.body}")
  Appsignal.send_error(StandardError.new("Failed to fetch Jito validators: #{response.body}"))
end
