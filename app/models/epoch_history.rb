# == Schema Information
#
# Table name: epoch_histories
#
#  id             :bigint           not null, primary key
#  batch_uuid     :string(191)
#  current_slot   :bigint
#  epoch          :integer
#  network        :string(191)
#  slot_index     :integer
#  slots_in_epoch :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_epoch_histories_on_network_and_batch_uuid  (network,batch_uuid)
#
class EpochHistory < ApplicationRecord

  def to_builder
    Jbuilder.new do |epoch_history|
      epoch_history.(
        self,
        :epoch
      )
    end
  end
end
