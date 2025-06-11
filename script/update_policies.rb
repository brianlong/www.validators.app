# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

log_path = Rails.root.join('log', 'update_policies.log')
logger = Rails.logger.new(log_path)
timestamp = Time.now.utc.strftime('%Y%m%d%H%M')

fork { exec('node', './get_policies.js', timestamp) }

# Wait for the node process to finish
Process.wait

# Check if the node process exited successfully
if $?.success?
  logger.info("New policies json file created at: storage/policies/decoded_policies_#{timestamp}.json")
  json = Rails.root.join('storage', 'policies', "decoded_policies_#{timestamp}.json").read
  policies = JSON.parse(json)

  # policies.each do |policy|
  #   Policy.find_or_create_by(
  #     mint: policy['mint']
  #   ).update(
  #     name: policy['name'],
  #     owner: policy['owner'],
  #     url: policy['url'],
  #     lamports: policy['lamports'],
  #     rent_epoch: policy['rent_epoch'],
  #     kind: policy["data"]['kind'],
  #     strategy: policy["data"]['strategy'],
  #     executable: policy['executable']
  #   )

  #   policy["data"]["identities"].each do |identity|
  #     validator = Validator.where(account: identity).first
  #     if validator
  #       PolicyValidator.find_or_create_by(policy: policy, validator: validator)
  #     end
  #   end
  #   logger.info("Policy updated or created: #{policy['mint']}")
  # end
  
else
  logger.error("Failed to update policies. Node process exited with status: #{$?.exitstatus}")
end

# Exit the script with the same status as the node process
exit $?.exitstatus
