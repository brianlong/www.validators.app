# == Schema Information
#
# Table name: commission_histories
#
#  id                :bigint           not null, primary key
#  batch_uuid        :string(191)
#  commission_after  :float(24)
#  commission_before :float(24)
#  epoch             :integer
#  epoch_completion  :float(24)
#  network           :string(191)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  validator_id      :bigint           not null
#
# Indexes
#
#  index_commission_histories_on_epoch                     (epoch)
#  index_commission_histories_on_network_and_validator_id  (network,validator_id)
#  index_commission_histories_on_validator_id              (validator_id)
#  index_commission_histories_on_validators                (network,created_at,validator_id)
#
# Foreign Keys
#
#  fk_rails_...  (validator_id => validators.id)
#
class CommissionHistory < ApplicationRecord
  belongs_to :validator

  after_commit :notify_users, on: :create

  def rising?
    commission_after.to_i > commission_before.to_i
  end

  private

  def notify_users
    validator.watchers.each do |watcher|
      CommissionHistoryMailer.commission_change_info(
        user: watcher,
        validator: validator,
        commission: self
      ).deliver_later
    end
  end
end
