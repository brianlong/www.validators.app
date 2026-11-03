# frozen_string_literal: true

module AlpenglowLogic
  def alpenglow_vote_credits_get
    lambda do |p|
      return p unless p[:code] == 200
      return p unless p.payload[:network].in?(ALPENGLOW_NETWORKS)

      vote_accounts = AlpenglowVoteRewardsService.new(
        config_urls: p.payload[:config_urls],
        epoch: p.payload[:epoch],
        epoch_start_slot: p.payload[:epoch_start_slot],
        slot_index: p.payload[:epoch_slot_index]
      ).call(p.payload[:vote_accounts], p.payload[:total_vote_accounts_stake])

      Pipeline.new(200, p.payload.merge(vote_accounts: vote_accounts))
    rescue StandardError => e
      Appsignal.send_error(e)
      p
    end
  end
end
