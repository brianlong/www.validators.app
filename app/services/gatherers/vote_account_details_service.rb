# frozen_string_literal: true

module Gatherers

  # Assigns validator_identit
  class VoteAccountDetailsService
    include SolanaLogic

    SCORE_OPTIONS = {
      negative: -2,
      neutral: 0
    }

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
        if vote_account_details.blank?
          vacc.touch_inactive
        else
          if should_omit_update?(vacc, vote_account_details) || vacc.update(
            validator_identity: vote_account_details["validatorIdentity"],
            authorized_withdrawer: vote_account_details["authorizedWithdrawer"],
            is_active: true
          )
            update_score(vacc)
          else
            vacc.touch_inactive
          end
        end
      end
    rescue ActiveRecord::LockWaitTimeout => e
      sleep 5
      retry
    end

    private

    def should_omit_update?(vacc, vote_account_details)
      vacc.validator_identity == vote_account_details["validatorIdentity"] && \
      vacc.authorized_withdrawer == vote_account_details["authorizedWithdrawer"]
    end

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
        vacc.validator.validator_score_v1.authorized_withdrawer_score = SCORE_OPTIONS[:negative]
      else
        vacc.validator.validator_score_v1.authorized_withdrawer_score = SCORE_OPTIONS[:neutral]
      end
      vacc.validator.validator_score_v1.save if vacc.validator.validator_score_v1.authorized_withdrawer_score_changed?
    end
  end
end
