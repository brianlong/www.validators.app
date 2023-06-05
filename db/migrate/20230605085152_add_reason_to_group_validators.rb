class AddReasonToGroupValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :group_validators, :link_reason, :text
  end
end
