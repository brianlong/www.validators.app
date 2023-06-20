# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

log_path = File.join(Rails.root, 'log', 'add_validator_id_to_validator_histories.log')
logger = Logger.new(log_path)

Validator.find_each do |validator|
  ValidatorHistory.where(network: validator.network, account: validator.account)
                  .update_all(validator_id: validator.id)
rescue StandardError => e
  logger.error "Error_class: #{e.class}, message: #{e.message}\n#{e.backtrace}"
  puts 'Error occurred, more info in log/add_validator_id_to_validator_histories.log'
end
