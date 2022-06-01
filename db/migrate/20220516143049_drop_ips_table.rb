class DropIpsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :ips, if_exist: :true
  end
end
