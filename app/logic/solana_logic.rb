# frozen_string_literal: true

# SolanaLogic contains methods used for importing data from the solana runtime.
# Many of these methods are simple wrappers for shell commands. These methods
# are lambdas that we can use in a processing pipeline for various purposes.
#
# See `config/initializers/pipeline.rb` for a description of the Pipeline struct
module SolanaLogic
  # validators_get returns the data from RPC 'getClusterNodes'
  def validators_get
    lambda do |p|
      return p unless p[:code] == 200

      validators_json = rpc_request(
        'getClusterNodes',
        p[:payload][:config_url]
      )['result']

      validators = {}
      validators_json.each do |hash|
        validators[hash['pubkey']] = {
          'gossip_ip_port' => hash['gossip'],
          'rpc_ip_port' => hash['rpc'],
          'tpu_ip_port' => hash['tpu'],
          'version' => hash['version']
        }
      end

      Pipeline.new(200, p[:payload].merge(validators: validators))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from validators_get', e)
    end
  end

  # vote_accounts_get returns the data from RPC 'getVoteAccounts'
  def vote_accounts_get
    lambda do |p|
      return p unless p[:code] == 200

      vote_accounts_json = rpc_request(
        'getVoteAccounts',
        p[:payload][:config_url]
      )['result']['current']

      vote_accounts = {}
      vote_accounts_json.each do |hash|
        vote_accounts[hash['nodePubkey']] = {
          'vote_account' => hash['votePubkey'],
          'activated_stake' => hash['activatedStake'],
          'commission' => hash['commission'],
          'last_vote' => hash['lastVote'],
          'credits' => hash['epochCredits'][-1][1]
        }
      end

      Pipeline.new(200, p[:payload].merge(vote_accounts: vote_accounts))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from vote_accounts_get', e)
    end
  end

  # reduce the two validators and vote_accounts Hashes into a single structure
  def reduce_validator_vote_accounts
    lambda do |p|
      return p unless p[:code] == 200

      validators_reduced = {}
      p[:payload][:validators].each do |k, _v|
        next if p[:payload][:vote_accounts][k].nil?

        validators_reduced[k] = \
          p[:payload][:validators][k].merge(p[:payload][:vote_accounts][k])
      end

      Pipeline.new(
        200,
        p[:payload].merge(validators_reduced: validators_reduced)
      )
    rescue StandardError => e
      Pipeline.new(
        500,
        p[:payload],
        'Error from reduce_validator_vote_accounts',
        e
      )
    end
  end

  # Save data to the DB
  def validators_save
    lambda do |p|
      return p unless p[:code] == 200

      p[:payload][:validators_reduced].each do |k, v|
        # Find or create the validator record
        validator = Validator.find_or_create_by(
          network: p[:payload][:network],
          account: k
        )

        # Find or create the vote_account record
        vote_account = validator.vote_accounts.find_or_create_by(
          account: v['vote_account']
        )

        # Create Vote records to save a time series of vote & stake data
        vote_account.votes.create(
          commission: v['commission'],
          last_vote: v['last_vote'],
          credits: v['credits'],
          activated_stake: v['activated_stake'],
          software_version: v['version']
        )

        # Find or create the validator IP address
        _ip = validator.validator_ips.find_or_create_by(
          version: 4,
          address: v['gossip_ip_port'].split(':')[0]
        )
      end

      Pipeline.new(200, p[:payload])
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from validators_save', e)
    end
  end

  # rpc_request will make a Solana RPC request and return the results in a
  # JSON object. API specifications are at:
  #
  #   https://docs.solana.com/apps/jsonrpc-api#json-rpc-api-reference
  def rpc_request(rpc_method, rpc_url)
    # Parse the URL data into an URI object
    uri = URI.parse(
      "#{rpc_url}:#{Rails.application.credentials.solana[:rpc_port]}"
    )

    # Create the HTTP session and send the request
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Post.new(
        uri.request_uri,
        { 'Content-Type' => 'application/json' }
      )
      request.body = {
        'jsonrpc': '2.0', 'id': 1, 'method': rpc_method.to_s
      }.to_json
      http.request(request)
    end
    JSON.parse(response.body)
  end
end
