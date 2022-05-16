class DropIpOverrideTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :ip_overrides, if_exist: true
  end
end
