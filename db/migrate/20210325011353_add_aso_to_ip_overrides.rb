class AddAsoToIpOverrides < ActiveRecord::Migration[6.1]
  def change
    add_column :ip_overrides, :traits_autonomous_system_organization, :string
  end
end
