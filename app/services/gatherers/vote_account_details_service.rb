# frozen_string_literal: true

module Gatherers

  # Assigns validator_identit
  class VoteAccountDetailsService
    include SolanaRequestsLogic

    def initialize(network:, config_urls:, always_update: false)
      @always_update = always_update
      @network = network
      @config_urls = config_urls
      @retry_count = 0
    end

    def call
      VoteAccount.where(network: @network).find_each(batch_size: 200) do |vacc|
        vote_account_details = get_vote_account_details(vacc.account)

        if vote_account_details.blank? || vote_account_details["validatorIdentity"].blank?
          vacc.set_inactive_without_touch
          next
        end

        next if !@always_update && should_omit_update?(vacc, vote_account_details)

        ActiveRecord::Base.transaction do
          vacc.update(
            validator_identity: vote_account_details["validatorIdentity"],
            authorized_withdrawer: vote_account_details["authorizedWithdrawer"],
            authorized_voters: vote_account_details["authorizedVoters"]
          )
          update_score(vacc)
        end
      end
    rescue ActiveRecord::LockWaitTimeout => e
      sleep 5
      @retry_count += 1
      retry if @retry_count < 3
    rescue StandardError => e
      sleep 5
      @retry_count += 1
      if @retry_count < 3
        retry
      else
        raise e
      end
    end

    private

    def should_omit_update?(vacc, vote_account_details)
      vacc.validator_identity == vote_account_details["validatorIdentity"] &&
        vacc.authorized_withdrawer == vote_account_details["authorizedWithdrawer"] &&
        vacc.authorized_voters == vote_account_details["authorizedVoters"]
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

      score = vacc.validator.score
      return unless score

      if vacc.validator_identity == vacc.authorized_withdrawer
        score.authorized_withdrawer_score = ValidatorScoreV1::WITHDRAWER_SCORE_OPTIONS[:negative]
      else
        score.authorized_withdrawer_score = ValidatorScoreV1::WITHDRAWER_SCORE_OPTIONS[:neutral]
      end
      score.save if score.authorized_withdrawer_score_changed?
    end
  end
end
