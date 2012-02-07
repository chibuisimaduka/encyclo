class CreateDeleteRequests < ActiveRecord::Migration
  def change
    create_table :delete_requests do |t|
      t.integer :entity_id
      t.integer :user_id

      t.timestamps
    end
  end
end
