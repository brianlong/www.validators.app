# frozen_string_literal: true

class AlpenglowVoteRewardsService
  VOTE_REWARD_ACCOUNT = "3vJzniWALu2qGFJ1ZY6JD3Y2ZmA5zWqmVdDX7yBXHgu7"
  EPOCH_CREDITS_SENTINEL = 18_446_744_073_709_551_615
  RPC_TIMEOUT = 30

  class EpochInflationStateMissing < StandardError; end

  @leader_schedules = {}

  class << self
    attr_reader :leader_schedules
  end

  def initialize(config_urls:, epoch:, epoch_start_slot:, slot_index:)
    @config_urls = config_urls
    @epoch = epoch
    @epoch_start_slot = epoch_start_slot
    @slot_index = slot_index
  end

  def call(vote_accounts, total_stake)
    inflation_state = epoch_inflation_state
    migration_slot = fetch_migration_slot
    migration_epoch = migration_slot >= @epoch_start_slot
    first_rewarded_index = migration_epoch ? migration_slot - @epoch_start_slot + 1 : 0
    schedule = leader_schedule

    vote_accounts.to_h do |node_pubkey, vote_account|
      [
        node_pubkey,
        vote_account.merge(
          "credits_current" => epoch_credits_current(vote_account["epoch_credits"], migration_epoch),
          "max_credits_current" => max_credits(
            inflation_state,
            rewarded_slots: @slot_index - first_rewarded_index,
            leader_slots: leader_slots_count(schedule[node_pubkey], first_rewarded_index),
            stake: vote_account["activated_stake"].to_i,
            total_stake: total_stake.to_i
          )
        )
      ]
    end
  end

  def epoch_inflation_state
    data = Base64.decode64(
      rpc_request("getAccountInfo", [VOTE_REWARD_ACCOUNT, { encoding: "base64" }]).dig("value", "data", 0).to_s
    )
    current = decode_epoch_state(data, 0)
    return current if current && current[:epoch] == @epoch

    previous = decode_epoch_state(data, 25) if data.bytesize >= 49 && data.getbyte(24) == 1
    return previous if previous && previous[:epoch] == @epoch

    raise EpochInflationStateMissing, "no epoch inflation state for epoch #{@epoch}"
  end

  def max_credits(inflation_state, rewarded_slots:, leader_slots:, stake:, total_stake:)
    return 0 if rewarded_slots <= 0 || stake <= 0 || total_stake <= 0

    reward_per_slot = inflation_state[:max_possible_validator_reward]
    slots_per_epoch = inflation_state[:slots_per_epoch]
    voter_credits = (rewarded_slots * reward_per_slot * stake) / (2 * slots_per_epoch * total_stake)
    leader_credits = (leader_slots * reward_per_slot) / (2 * slots_per_epoch)

    voter_credits + leader_credits
  end

  def leader_slots_count(slot_indexes, first_rewarded_index)
    return 0 if slot_indexes.blank?

    upper = slot_indexes.bsearch_index { |index| index >= @slot_index } || slot_indexes.size
    lower = slot_indexes.bsearch_index { |index| index >= first_rewarded_index } || slot_indexes.size
    [upper - lower, 0].max
  end

  def epoch_credits_current(epoch_credits, migration_epoch)
    epoch_credits = epoch_credits.to_a
    last_entry = epoch_credits.last
    return 0 if last_entry.blank? || sentinel?(last_entry) || last_entry[0].to_i != @epoch
    return 0 if migration_epoch && !sentinel?(epoch_credits[-2])

    last_entry[1].to_i - last_entry[2].to_i
  end

  private

  def sentinel?(entry)
    entry.present? && entry.all? { |value| value.to_i == EPOCH_CREDITS_SENTINEL }
  end

  def decode_epoch_state(data, offset)
    return nil if data.bytesize < offset + 24

    max_possible_validator_reward, slots_per_epoch, epoch = data.byteslice(offset, 24).unpack("Q<Q<Q<")
    {
      max_possible_validator_reward: max_possible_validator_reward,
      slots_per_epoch: slots_per_epoch,
      epoch: epoch
    }
  end

  def leader_schedule
    key = [@config_urls.first, @epoch]
    cache = self.class.leader_schedules
    return cache[key] if cache.key?(key)

    schedule = rpc_request("getLeaderSchedule", [@epoch_start_slot]).transform_values(&:sort)
    cache.clear
    cache[key] = schedule
  end

  def fetch_migration_slot
    rpc_request("getAgGenesisCert").dig("block", "slot").to_i
  end

  def rpc_request(method, params = [])
    errors = []
    @config_urls.each do |url|
      uri = URI(url)
      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      request.body = { jsonrpc: "2.0", id: 1, method: method, params: params }.to_json
      response = Net::HTTP.start(
        uri.hostname, uri.port, use_ssl: uri.scheme == "https", open_timeout: RPC_TIMEOUT, read_timeout: RPC_TIMEOUT
      ) { |http| http.request(request) }
      result = JSON.parse(response.body)["result"]
      return result if result.present?

      errors << "#{uri.host}: empty result"
    rescue StandardError => e
      errors << "#{uri&.host}: #{e.class} #{e.message}"
    end
    raise "#{method} failed: #{errors.join('; ')}"
  end
end
