# frozen_string_literal: true

class AccountAuthorityQuery
  def initialize(network: "mainnet", vote_account: nil, validator: nil)
    @network = network
    @vote_account_param = vote_account
    @validator_param = validator

    @vote_account = VoteAccount.find_by(account: vote_account, network: network)
    @validator = Validator.find_by(account: validator, network: network)

    @results = AccountAuthorityHistory.joins(:vote_account).where(network: network)
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
