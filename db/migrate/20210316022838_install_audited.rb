class InstallAudited < ActiveRecord::Migration[6.1]
  def self.up
    create_table :audits, force: true do |t|
      t.column :auditable_id, :bigint, unsigned: true
      t.column :auditable_type, :string
      t.column :associated_id, :bigint, unsigned: true
      t.column :associated_type, :string
      t.column :user_id, :bigint, unsigned: true
      t.column :user_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :audited_changes, :text
      t.column :version, :integer, default: 0
      t.column :comment, :string
      t.column :remote_address, :string
      t.column :request_uuid, :string
      t.column :created_at, :datetime
    end

    add_index :audits, %i[auditable_type auditable_id version],
              name: 'auditable_index'
    add_index :audits, %i[associated_type associated_id],
              name: 'associated_index'
    add_index :audits, %i[user_type user_id], name: 'user_index'
    add_index :audits, :request_uuid
    add_index :audits, :created_at
  end

  def self.down
    drop_table :audits
  end
end
