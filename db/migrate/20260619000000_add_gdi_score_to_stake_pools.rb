# frozen_string_literal: true

class AddGdiScoreToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :gdi_score, :float
  end
end
