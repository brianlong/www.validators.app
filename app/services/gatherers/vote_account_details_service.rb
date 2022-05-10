# frozen_string_literal: true

module Gatherers

  # Assigns validator_identit
  class VoteAccountDetailsService
    include SolanaLogic

    def initialize(network:, config_urls:)
      @network = network
      @config_urls = config_urls
      @range_start = VoteAccount.where(network: @network).order(id: :asc).first.id
      @range_end = VoteAccount.where(network: @network).order(id: :asc).last.id
    end

    def call
      VoteAccount.where(id: @range_start..@range_end, network: @network)
                 .order(id: :asc)
                 .each do |vacc|
        @range_start = vacc.id

        vote_account_details = get_vote_account_details(vacc.account)
        unless vote_account_details.blank?
          vacc.update(
            validator_identity: vote_account_details["validatorIdentity"],
            authorized_withdrawer: vote_account_details["authorizedWithdrawer"]
          )

          update_score(vacc)
        end
      end
    rescue ActiveRecord::LockWaitTimeout => e
      sleep 5
      retry
    end

    private

    # solana vote-account <account >
    def get_vote_account_details(account)
      cli_request(
        "vote-account #{account}",
        @config_urls
      )
    end

    # -2 points if withdrawer and id are the same
    def update_score(vacc)
      return unless vacc

      if vacc.validator_identity == vacc.authorized_withdrawer
        vacc.validator.validator_score_v1.update(authorized_withdrawer_score: -2)
      else
        vacc.validator.validator_score_v1.update(authorized_withdrawer_score: 0)
      end
    end
  end
end
