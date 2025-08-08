class UpdatePoliciesService
  def initialize(policies: [], network: "mainnet", logger: Rails.logger)
    @logger = logger
    @policies = policies
    @network = network
    @pubkeys = policies.map { |policy| policy['pubkey'] }
  end

  def call
    destroy_nonexistent_policies
    @logger.info("Updating policies for network: #{@network}")
    @policies.each do |policy|
      db_policy = Policy.find_or_create_by(
        pubkey: policy['pubkey'],
        network: @network,
      )

      metadata = if policy['token_metadata'] && policy['token_metadata']['uri']
        metadata_uri = URI(policy['token_metadata']['uri'])
        get_metadata(metadata_uri)
      else
        {}
      end

      db_policy.update(
        owner: policy['owner'],
        lamports: policy['lamports'],
        rent_epoch: policy['rent_epoch'],
        kind: [0, 1].include?(policy["data"]['kind']) ? policy["data"]['kind'] : "v2",
        strategy: policy["data"]['strategy'],
        executable: policy['executable'],
        name: policy['token_metadata'] ? policy['token_metadata']['name'] : nil,
        url: policy['token_metadata'] ? policy['token_metadata']['uri'] : nil,
        mint: policy['token_metadata'] ? policy['token_metadata']['mint'] : nil,
        symbol: policy['token_metadata'] ? policy['token_metadata']['symbol'] : nil,
        image_url: metadata["image"],
        description: metadata["description"] || policy['token_metadata']&.dig('description'),
        additional_metadata: policy['token_metadata'] ? policy['token_metadata']['additionalMetadata'] : nil,
        token_holders: policy['token_holders'] || []
      )

      update_policy_identities(db_policy, policy["data"]["identities"])

      UpdateImageFileService.new(db_policy, :image).call(keep_tmp_files: true) if db_policy.image_url.present?
    end
  end

  private

  def update_policy_identities(db_policy, identities)
    PolicyIdentity.where(policy_id: db_policy.id).where.not(account: identities).destroy_all
    
    identities.each do |identity|
      validator = Validator.where(account: identity).first

      PolicyIdentity.find_or_create_by(
        policy_id: db_policy.id,
        validator_id: validator&.id,
        account: identity
      )
    end
  end

  def destroy_nonexistent_policies
    Policy.where(network: @network).where.not(pubkey: @pubkeys).find_each do |policy|
      policy.destroy
    end
  end

  def get_metadata(uri)
    begin
      Timeout.timeout(10) do
        response = Net::HTTP.get_response(uri)
        if response.code == '302'
          uri = URI(response.header['Location'])
          response = Net::HTTP.get_response(uri)
        end
        return JSON.parse(response.body) if response.code == '200'
      end
    rescue StandardError => e
      @logger.error("Error fetching metadata from #{uri}: #{e.message}")
      Appsignal.send_error(e)
      {}
    end
    {}
  end
end
