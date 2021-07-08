# frozen_string_literal: true

# creates new commission_history for a validator if commission has changed
class CreateCommissionHistoryService
  def initialize(validator_history)
    @recent_history = validator_history
    @previous_history = @recent_history.previous
  end

  # payload returns CommissionHistory object if it has been created
  # otherwise it returns false
  def call
    result = commission_changed? ? create_commission : false
  rescue StandardError => e
    OpenStruct.new({ success?: false, error: e })
  else
    OpenStruct.new({ success?: true, payload: result })
  end

  private

  def commission_changed?
    @recent_history.commission != @previous_history.commission
  end

  def create_commission
    associated_validator.commission_histories.create(
      commission_before: @previous_history.commission,
      commission_after: @recent_history.commission,
      batch_uuid: @recent_history.batch_uuid
    )
  end

  def associated_validator
    Validator.find_by(account: @recent_history.account)
  end
end
