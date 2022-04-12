class AddValidatorsAvatarUrl < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :avatar_url, :string
  end
end
