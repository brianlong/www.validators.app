class AddMaxHeightColumsToValidatorHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_histories, :epoch_credits, :integer, unsigned: true
    add_column :validator_histories, :slot_skip_rate, :float, unsigned: true
    add_column :validator_histories, :max_root_height, :bigint, unsigned: true
    add_column :validator_histories, :root_distance, :bigint, unsigned: true
    add_column :validator_histories, :max_vote_height, :bigint, unsigned: true
    add_column :validator_histories, :vote_distance, :bigint, unsigned: true
  end
end
