# frozen_string_literal: true

class AccountAuthorityQuery
  def initialize(network: "mainnet", vote_account: nil, validator: nil)
    @network = network
    @vote_account = VoteAccount.find_by(account: vote_account, network: network)
    @validator = Validator.find_by(account: validator, network: network)

    @results = AccountAuthorityHistory.where(network: network)
  end

  def call
    if @vote_account.present?
      # raise error if vote account and validator mismatch
      raise ArgumentError.new("validator and vote account mismatch") \
        unless @validator.nil? || @vote_account.validator == @validator

      @results = @results.where(vote_account_id: @vote_account.id)
    elsif @validator.present?
      @results = @results.where(vote_account_id: @validator.vote_accounts.pluck(:id))
    end

    @results.order(created_at: :desc)
  end
end
