# frozen_string_literal: true

module Gatherers

  # Assigns validator_identit
  class VoteAccountDetailsService
    include SolanaLogic

    def initialize(network:, config_urls:)
      @network = network
      @config_urls = config_urls
    end

    def call
      VoteAccount.where(network: @network).each do |vacc|
        vote_account_details = get_vote_account_details(vacc.account)
        if vote_account_details.blank?
          vacc.set_inactive
        else
          if vacc.update(
            validator_identity: vote_account_details["validatorIdentity"],
            authorized_withdrawer: vote_account_details["authorizedWithdrawer"],
            is_active: true
          )
            update_score(vacc)
          else
            vacc.set_inactive
          end
        end
      end
    end

    private

    # solana vote-account <account>
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
        vacc.validator.validator_score_v1.authorized_withdrawer_score = -2
      else
        vacc.validator.validator_score_v1.authorized_withdrawer_score = 0
      end
      vacc.validator.validator_score_v1.save if vacc.validator.validator_score_v1.authorized_withdrawer_score_changed?
    end
  end
end
