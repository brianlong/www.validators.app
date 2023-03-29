# frozen_string_literal: true

class AddDefaultTimestampsToValidators < ActiveRecord::Migration[6.1]
  def up
    change_column :validators, :created_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    change_column :validators, :updated_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end

  def down
    change_column :validators, :created_at, :datetime, limit: 6
    change_column :validators, :updated_at, :datetime, limit: 6
  end
end
