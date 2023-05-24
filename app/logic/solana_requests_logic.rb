# frozen_string_literal: true

module SolanaRequestsLogic
  RPC_TIMEOUT = 60 # seconds

  # Clusters array, method symbol
  def solana_client_request(clusters, method, params: nil)
    clusters.each do |cluster_url|
      client = SolanaRpcClient.new(cluster: cluster_url).client
      response = if params
                   client.public_send(method, params.first, **params.last).result
                 else
                   client.public_send(method).result
                 end

      return response unless response.blank?
    rescue SolanaRpcRuby::ApiError => e
      Appsignal.send_error(e) if Rails.env.in?(['stage', 'production'])
      message = "Request to solana RPC failed:\n Method: #{method}\nCluster: #{cluster_url}\nCLASS: #{e.class}\n#{e.message}"
      Rails.logger.error(message)
      nil
    end
  end

  # cli_request will accept a command line command to run and then return the
  # results as parsed JSON. [] is returned if there is no data
  def cli_request(cli_method, rpc_urls)
    rpc_urls.each do |rpc_url|
      response_json = Timeout.timeout(RPC_TIMEOUT) do

        SolanaCliService.request(cli_method, rpc_url)

      rescue Errno::ENOENT, Errno::ECONNREFUSED, Timeout::Error => e
        # Log errors and return '' if there is a problem
        Rails.logger.error "CLI TIMEOUT\n#{e.class}\nRPC URL: #{rpc_url}"
        ''
      end
      # puts response_json
      response_utf8 = response_json.encode(
                            'UTF-8',
                            invalid: :replace,
                            undef: :replace
                          )
      # If the response includes extra notes at the top, we need to
      # strip the notes before parsing JSON
      #
      # "\nNote: Requested start slot was 63936000 but minimum ledger slot is 63975209\n{
      if response_utf8.include?('Note: ')
        note_end_index = response_utf8.index("\n{")+1
        response_utf8 = response_utf8[note_end_index..-1]
      end

      # byebug

      return JSON.parse(response_utf8) unless response_utf8 == ''
    rescue JSON::ParserError => e
      Rails.logger.error "CLI ERROR #{e.class} RPC URL: #{rpc_url} for #{cli_method}\n#{response_utf8}"
    end
    []
  end
end
