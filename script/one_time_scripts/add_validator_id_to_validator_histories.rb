# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

Validator.find_each do |validator|
  ValidatorHistory.where(network: validator.network, account: validator.account)
                  .update_all(validator_id: validator.id)
end
