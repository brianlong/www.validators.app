# frozen_string_literal: true

class AddValidatorInfo < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :details, :string
    add_column :validators, :info_pub_key, :string
  end
end
