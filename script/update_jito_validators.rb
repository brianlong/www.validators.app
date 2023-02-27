# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'uri'
require 'net/http'


uri = URI("https://kobe.mainnet.jito.network/api/v1/validators")
response = Net::HTTP.get_response(uri)
if response.is_a?(Net::HTTPSuccess)
  json_response = JSON.parse(response.body)
  jito_vote_accounts = json_response["validators"].map do |jito_validator|
    jito_validator["vote_account"] if jito_validator["running_jito"]
  end

  jito_db_validators = Validator.joins(:vote_accounts)
                                .where(
                                  "validators.network = ? AND vote_accounts.account IN (?)",
                                  "mainnet",
                                  jito_vote_accounts
                                )
  jito_db_validators.update_all(jito_collaboration: true)
  Validator.where.not(id: jito_db_validators.pluck(:id)).update_all(jito_collaboration: false)
end
