# frozen_string_literal: true

# creates new commission_history for a validator if commission has changed
class CreateCommissionHistoryService
  def initialize(score)
    @score = score
  end

  # payload returns CommissionHistory object if it has been created
  # otherwise it returns false
  def call
    commission_change = create_commission
  rescue StandardError => e
    OpenStruct.new({ success?: false, error: e })
  else
    OpenStruct.new({ success?: true, payload: commission_change })
  end

  private

  def create_commission
    @score.validator.commission_histories.create(
      commission_before: @score.commission_before_last_save,
      commission_after: @score.commission,
      batch_uuid: last_batch.uuid,
      epoch: recent_epoch.epoch,
      epoch_completion: recent_epoch_completion,
      network: recent_epoch.network
    )
  end

  def last_batch
    @last_batch ||= Batch.where(network: @score.network)
                         .order(created_at: :desc)
                         .first
  end

  def recent_epoch
    @recent_epoch ||= EpochHistory.find_by(
      batch_uuid: last_batch.uuid,
      network: @score.network
    )
  end

  def recent_epoch_completion
    ((recent_epoch.slot_index / recent_epoch.slots_in_epoch.to_f) * 100).round(2)
  end
end
