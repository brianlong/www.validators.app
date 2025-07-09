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
  json = Rails.root.join('storage', 'policies', "decoded_policies_#{timestamp}.json").read
  policies = JSON.parse(json)

  policies.each do |policy|

    db_policy = Policy.find_or_create_by(
      pubkey: policy['pubkey'],
      network: "mainnet",
    )
    metadata = {}
    if policy['token_metadata'] && policy['token_metadata']['uri']
      uri = URI(policy['token_metadata']['uri'])
      Timeout.timeout(10) do
        response = Net::HTTP.get_response(uri)
        if response.code == '302'
          uri = URI(response.header['Location'])
          response = Net::HTTP.get_response(uri)
          if response.code == '200'
            metadata = JSON.parse(response.body)
          end
        elsif response.code == '200'
          metadata = JSON.parse(response.body)
        end
      end

    end
    db_policy.update(
      owner: policy['owner'],
      lamports: policy['lamports'],
      rent_epoch: policy['rent_epoch'],
      kind: policy["data"]['kind'],
      strategy: policy["data"]['strategy'],
      executable: policy['executable'],
      name: policy['token_metadata'] ? policy['token_metadata']['name'] : nil,
      url: policy['token_metadata'] ? policy['token_metadata']['uri'] : nil,
      mint: policy['token_metadata'] ? policy['token_metadata']['mint'] : nil,
      symbol: policy['token_metadata'] ? policy['token_metadata']['symbol'] : nil,
      image: metadata["image"],
      description: metadata["description"] || policy['token_metadata']&.dig('symbol'),
      additional_metadata: policy['token_metadata'] ? policy['token_metadata']['additionalMetadata'] : nil,
    )

    policy["data"]["identities"].each do |identity|
      validator = Validator.where(account: identity).first
      PolicyIdentity.find_or_create_by(
        policy_id: db_policy.id,
        validator_id: validator&.id,
        account: identity
      )
    end
    logger.info("Policy updated or created: #{policy['pubkey']}")
  end

else
  logger.error("Failed to update policies. Node process exited with status: #{$?.exitstatus}")
end

# Exit the script with the same status as the node process
exit $?.exitstatus
