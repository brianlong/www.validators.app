# frozen_string_literal: true

module StakeLogic
  include PipelineLogic
  include SolanaLogic #for solana_client_request

  def get_last_batch
    lambda do |p|
      return p unless p.code == 200

      last_batch = Batch.last_scored(p.payload[:network])

      if last_batch.nil?
        raise "No batch: #{p.payload[:network]}, #{p.payload[:batch_uuid]}"
      end

      Pipeline.new(200, p.payload.merge(batch: last_batch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def get_stake_accounts
    lambda do |p|
      return p unless p.code == 200

      stake_accounts = cli_request(
        'stakes',
        p.payload[:config_urls]
      )

      Pipeline.new(200, p.payload.merge(
        stake_accounts: stake_accounts
      ))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_stake_accounts', e)
    end
  end
end
