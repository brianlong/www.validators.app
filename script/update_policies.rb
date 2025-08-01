# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

require 'uri'
require 'net/http'
require 'fileutils'

log_path = Rails.root.join('log', 'update_policies.log')
logger = Logger.new(log_path)
timestamp = Time.now.utc.strftime('%Y%m%d%H%M')
FileUtils.mkdir_p(Rails.root.join('storage', 'policies'))

fork { exec('node', './get_policies.js', timestamp) }

# Wait for the node process to finish
Process.wait

# Check if the node process exited successfully
if $?.success?
  logger.info("New policies json file created at: storage/policies/decoded_policies_#{timestamp}.json")

  # Read the JSON file created by the node script
  json = Rails.root.join('storage', 'policies', "decoded_policies_#{timestamp}.json").read
  policies = JSON.parse(json)

  # Update policies in the database
  UpdatePoliciesService.new(
    policies: policies,
    network: "mainnet",
    logger: logger
  ).call

  # Remove the temporary JSON file after processing
  FileUtils.rm(Rails.root.join('storage', 'policies', "decoded_policies_#{timestamp}.json"))
  logger.info("Policies updated successfully.")
else
  logger.error("Failed to update policies. Node process exited with status: #{$?.exitstatus}")
end

# Exit the script with the same status as the node process
exit $?.exitstatus
