

require File.expand_path('../config/environment', __dir__)
include SolanaLogic

dev_mode = true unless Rails.env.production?
rpc_urls = Rails.application.credentials.solana[:mainnet_urls]
network = 'mainnet'
look_back = 30 # slots

module BlockCommitmentSupport
  def commitment_request(slot, rpc_urls)
    # Parse the URL data into an URI object.
    # The mainnet RPC endpoint is not on port 8899. I am now including the port
    # with the URL inside of Rails credentials.
    # uri = URI.parse(
    #   "#{rpc_url}:#{Rails.application.credentials.solana[:rpc_port]}"
    # )

    rpc_urls.each do |rpc_url|
      uri = URI.parse(rpc_url)

      response_body = Timeout.timeout(RPC_TIMEOUT) do
        # Create the HTTP session and send the request
        response = Net::HTTP.start(
                     uri.host,
                     uri.port,
                     use_ssl: uri.scheme == 'https'
                   ) do |http|
          request = Net::HTTP::Post.new(
            uri.request_uri,
            { 'Content-Type' => 'application/json' }
          )
          request.body = {
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'getBlockCommitment',
            "params": [slot]
          }.to_json
          http.request(request)
        end

        response.body
      rescue Errno::ECONNREFUSED, Timeout::Error => e
        Rails.logger.error "RPC TIMEOUT #{e.class} RPC: #{rpc_url} for #{rpc_method.to_s}"
        nil
      end

      return JSON.parse(response_body) if response_body
    rescue JSON::ParserError => e
      Rails.logger.error "RPC ERROR #{e.class} RPC: #{rpc_url} for #{rpc_method.to_s}\n#{response_body}"
    end
  end
end
include BlockCommitmentSupport

# Send an interrupt with `ctrl-c` or `kill` to stop the script. Results will
# not be posted to the validators.app server.
interrupted = false
trap('INT') { interrupted = true }

puts ''

begin
  loop do
    rpc_response = rpc_request('getSlot', rpc_urls)
    current_slot = rpc_response['result']

    puts "CURRENT SLOT: #{current_slot}" if dev_mode

    (current_slot-look_back).upto(current_slot) do |slot|
      puts slot if dev_mode
      commitment_response = commitment_request(slot, rpc_urls)
      puts commitment_response['result'].inspect if dev_mode

      commitment = nil
      total_stake = nil
      if commitment_response && commitment_response['result']
        commitment = commitment_response['result']['commitment']
        total_stake = commitment_response['result']['totalStake']
      end

      BlockCommitment.stuff_it(
        network: network,
        slot: slot,
        commitment: commitment,
        total_stake: total_stake
      )

      puts '' if dev_mode
      break if interrupted
      sleep(1) if dev_mode
    end

    sleep(1) if dev_mode
    break if interrupted
  end
rescue StandardError => e
  puts "ERROR: #{e.message}"
  puts e.backtrace
end
puts '' if dev_mode
