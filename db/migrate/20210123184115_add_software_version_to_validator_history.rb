class AddSoftwareVersionToValidatorHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_histories, 'software_version', :string
  end
end
