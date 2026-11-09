class CreateXPosts < ActiveRecord::Migration[6.1]
  def change
    create_table :x_posts do |t|
      t.string :network
      t.string :kind
      t.string :reference_key, limit: 191, null: false
      t.bigint :validator_id
      t.bigint :parent_id
      t.text :message
      t.text :metadata
      t.string :status
      t.string :x_post_id
      t.text :error
      t.datetime :posted_at
      t.timestamps
    end

    add_index :x_posts, :reference_key, unique: true
    add_index :x_posts, [:network, :kind, :created_at]
    add_index :x_posts, :validator_id
    add_index :x_posts, :parent_id
  end
end
