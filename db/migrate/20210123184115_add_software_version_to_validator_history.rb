class AddSoftwareVersionToValidatorHistory < ActiveRecord::Migration[6.0]
  def change
    add_column :validator_histories, 'software_version', :string
  end
end
