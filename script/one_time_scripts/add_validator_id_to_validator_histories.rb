# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

ValidatorHistory.find_each do |vh|
  next if vh.validator

  validator = Validator.find_by(network: vh.network, account: vh.account)
  next unless validator

  ValidatorHistory.where(network: vh.network, account: vh.account)
                  .update_all(validator_id: validator.id)
end
