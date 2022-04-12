# frozen_string_literal: true

class UpdateNetworkIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :batches, %i[network created_at]
    remove_index :batches, :created_at
  end
end
