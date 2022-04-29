# frozen_string_literal: true

module Gatherers

  # Assigns validator_identit
  class VoteAccountDetailsService
    include SolanaLogic

    def initialize(network:, config_urls:)
      @network = network
      @config_urls = config_urls

      file_path = File.join(Rails.root, "log", "vote_account_details_service.log")
      @logger = Logger.new(file_path)
      @range_start = VoteAccount.where(network: @network).order(id: :asc).first.id
      @range_end = VoteAccount.where(network: @network).order(id: :asc).last.id
    end

    def call
      @logger.info("------------------ Script started (network: #{@network}) ------------------------")

      VoteAccount.where(id: @range_start..@range_end, network: @network)
                 .order(id: :asc)
                 .each do |vacc|
        @range_start = vacc.id

        vote_account_details = get_vote_account_details(vacc.account)
        if vote_account_details.blank?
          @logger.warn("CLI response error for #{vacc.id}, errors: #{vote_account_details}")
        else
          if vacc.update(
                validator_identity: vote_account_details["validatorIdentity"],
                authorized_withdrawer: vote_account_details["authorizedWithdrawer"]
              )
              @logger.info("VA #{vacc.id} updated successfully, v_identity: #{vote_account_details["validatorIdentity"]}, auth_withdrawer: #{vote_account_details["authorizedWithdrawer"]}")
            else
              @logger.warn("VA #{vacc.id} has not been updated successfully, v_identity: #{vote_account_details["validatorIdentity"]}, auth_withdrawer: #{vote_account_details["authorizedWithdrawer"]}, errors: #{vacc.errors.messages}")
          end

          update_score(vacc)
        end
        @logger.info("------------------------------------------")
      end

      @logger.info("------------------ Script is finished------------------------")
    rescue ActiveRecord::LockWaitTimeout => e
      @logger.error("Error: #{e.message}")
      @logger.info("Sleep 5 seconds...")
      sleep 5
      @logger.info("Retry...")
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
        if vacc.validator.validator_score_v1.update(authorized_withdrawer_score: -2)
          @logger.warn("-2 points for #{vacc.id}, updated.")
        else
          @logger.error("Update error, #{vacc.errors}.")
        end
      else
        if vacc.validator.validator_score_v1.update(authorized_withdrawer_score: 0)
          @logger.info("0 points for #{vacc.id}, updated.")
        else
          @logger.error("Update error, #{vacc.errors}.")
        end
      end
    end
  end
end
