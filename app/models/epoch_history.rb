# == Schema Information
#
# Table name: epoch_histories
#
#  id             :bigint           not null, primary key
#  batch_uuid     :string(255)
#  epoch          :integer
#  current_slot   :bigint
#  slot_index     :integer
#  slots_in_epoch :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  network        :string(255)
#
class EpochHistory < ApplicationRecord
end
