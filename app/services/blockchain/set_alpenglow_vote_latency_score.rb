# frozen_string_literal: true

module Blockchain
  class SetAlpenglowVoteLatencyScore
    include SolanaRequestsLogic

    def initialize(network)
      @network = network
      @config_urls = Rails.application.credentials.solana["#{network.tr('-', '_')}_urls".to_sym]
    end

    def call
      vote_accounts = fetch_vote_accounts
      return if vote_accounts.blank?

      max_last_vote = vote_accounts.map { |v| v["lastVote"].to_i }.max
      return if max_last_vote.zero?

      vote_accounts.each do |va|
        latency = (max_last_vote - va["lastVote"].to_i).to_f

        v = Validator.find_by(account: va["nodePubkey"], network: @network)
        next if v.blank? || v.score.blank?

        v.score.vote_latency_history_push(latency)
        v.score.save
        v.vote_account_active.vote_account_histories.last.update(vote_latency_average: latency) rescue next
      end
    end

    private

    def fetch_vote_accounts
      result = solana_client_request(@config_urls, :get_vote_accounts)
      result&.dig("current")
    end
  end
end
