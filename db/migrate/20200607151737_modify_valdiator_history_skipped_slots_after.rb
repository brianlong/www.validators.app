# frozen_string_literal: true

# ModifyValdiatorHistorySkippedSlotsAfter
class ModifyValdiatorHistorySkippedSlotsAfter < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_block_histories,
               :skipped_slots_after,
               :integer
    add_column :validator_block_histories,
               :skipped_slots_after_percent,
               :decimal, precision: 10, scale: 4
  end
end
