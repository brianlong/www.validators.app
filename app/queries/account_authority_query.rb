# frozen_string_literal: true

class AccountAuthorityQuery
  def initialize(network: "mainnet", vote_account: nil, validator: nil)
    @network = network
    @vote_account_param = vote_account
    @validator_param = validator

    @vote_account = VoteAccount.find_by(account: vote_account, network: network)
    @validator = Validator.find_by(account: validator, network: network)

    @results = AccountAuthorityHistory.joins(:vote_account)
                                      .includes(:vote_account)
                                      .where(network: network)
                                      .where("authorized_withdrawer_before IS NOT NULL \
                                              OR authorized_voters_before IS NOT NULL")
                                      .where("authorized_withdrawer_before <> authorized_withdrawer_after \
                                              OR authorized_voters_before <> authorized_voters_after")
  end

  def call
    if @vote_account.present?
      # raise error if vote account and validator mismatch
      raise ArgumentError.new("validator and vote account mismatch") \
        unless @validator.nil? || @vote_account.validator == @validator

      @results = @results.where(vote_account_id: @vote_account.id)
    elsif @validator.present?
      @results = @results.where(vote_account_id: @validator.vote_accounts.pluck(:id))
    elsif @vote_account_param || @validator_param
      @results = AccountAuthorityHistory.none
    end

    @results.order(created_at: :desc)
  end
end
