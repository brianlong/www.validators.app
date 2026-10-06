# frozen_string_literal: true

module Blockchain
  class AlpenglowEpochRanksService
    ACCOUNTS_BATCH_SIZE = 100
    BASE58_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    LOG_PATH = Rails.root.join("log", "#{name.demodulize.underscore}.log")

    def initialize(network:, config_urls: nil)
      @network = network
      @rpc = Blockchain::JsonRpcRequest.new(config_urls || NETWORK_URLS[network])
      @logger = Logger.new(LOG_PATH)
    end

    def call
      current_epoch = @rpc.call("getEpochInfo")&.dig("epoch")
      return if current_epoch.nil?

      build_provisional_ranks(current_epoch + 1)
      finalize_ranks(current_epoch)
    end

    private

    def build_provisional_ranks(epoch)
      return if AlpenglowEpochRank.where(network: @network, epoch: epoch).exists?

      candidates = sort_by_stake(staked_candidates)
      return if candidates.empty?

      save_ranks(epoch, candidates, finalized: false)
      @logger.info("Saved #{candidates.size} provisional ranks for epoch #{epoch} on #{@network}")
    end

    def finalize_ranks(epoch)
      provisional = AlpenglowEpochRank.where(network: @network, epoch: epoch, finalized: false).order(:rank).to_a
      return if provisional.empty?

      members = epoch_vote_accounts
      return if members.nil?

      candidates = provisional.select { |row| members.include?(row.vote_account) }.map do |row|
        row.attributes.symbolize_keys.slice(:vote_account, :validator_identity, :bls_pubkey, :stake)
           .merge(bls_bytes: base58_decode(row.bls_pubkey))
      end
      ranked = sort_by_stake(deduplicate(candidates))

      AlpenglowEpochRank.transaction do
        AlpenglowEpochRank.where(network: @network, epoch: epoch).delete_all
        save_ranks(epoch, ranked, finalized: true)
      end
      @logger.info(
        "Finalized #{ranked.size} ranks for epoch #{epoch} on #{@network} " \
        "(#{provisional.size - ranked.size} removed)"
      )
    end

    def save_ranks(epoch, candidates, finalized:)
      now = Time.current
      AlpenglowEpochRank.insert_all(
        candidates.each_with_index.map do |candidate, rank|
          candidate.except(:bls_bytes).merge(
            network: @network, epoch: epoch, rank: rank, finalized: finalized, created_at: now, updated_at: now
          )
        end
      )
    end

    def staked_candidates
      vote_accounts = @rpc.call("getVoteAccounts")
      return [] if vote_accounts.blank?

      staked = vote_accounts.values_at("current", "delinquent").flatten.compact.select { |va| va["activatedStake"].to_i.positive? }
      bls_pubkeys = fetch_bls_pubkeys(staked.map { |va| va["votePubkey"] })

      staked.filter_map do |va|
        bls_pubkey = bls_pubkeys[va["votePubkey"]]
        next if bls_pubkey.blank?

        {
          vote_account: va["votePubkey"],
          validator_identity: va["nodePubkey"],
          bls_pubkey: bls_pubkey,
          bls_bytes: base58_decode(bls_pubkey),
          stake: va["activatedStake"].to_i
        }
      end
    end

    def deduplicate(candidates)
      bls_counts = candidates.map { |c| c[:bls_bytes] }.tally
      identity_counts = candidates.map { |c| c[:validator_identity] }.tally

      candidates.select { |c| bls_counts[c[:bls_bytes]] == 1 && identity_counts[c[:validator_identity]] == 1 }
    end

    def sort_by_stake(candidates)
      candidates.sort { |a, b| [b[:stake], a[:bls_bytes]] <=> [a[:stake], b[:bls_bytes]] }
    end

    def epoch_vote_accounts
      result = @rpc.call("getVoteAccounts", [{ keepUnstakedDelinquents: true }])
      return nil unless result.is_a?(Hash)

      result.values_at("current", "delinquent").flatten.compact
            .select { |va| va["epochVoteAccount"] }
            .map { |va| va["votePubkey"] }
            .to_set
    end

    def fetch_bls_pubkeys(vote_accounts)
      vote_accounts.each_slice(ACCOUNTS_BATCH_SIZE).each_with_object({}) do |batch, bls_pubkeys|
        accounts = @rpc.call("getMultipleAccounts", [batch, { encoding: "jsonParsed" }])
        raise "Failed to fetch vote accounts data" if accounts.nil?

        accounts["value"].zip(batch).each do |account, vote_account|
          bls_pubkeys[vote_account] = account&.dig("data", "parsed", "info", "blsPubkeyCompressed")
        end
      end
    end

    def base58_decode(value)
      number = value.each_char.inject(0) { |acc, char| acc * 58 + BASE58_ALPHABET.index(char) }
      hex = number.zero? ? "" : number.to_s(16)
      hex = "0#{hex}" if hex.size.odd?
      ("\x00" * value[/\A1*/].size).b + [hex].pack("H*")
    end
  end
end
