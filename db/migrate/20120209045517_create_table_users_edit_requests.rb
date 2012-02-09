class CreateTableUsersEditRequests < ActiveRecord::Migration
  def change
    create_table :users_edit_requests, :id => false do |t|
      t.integer :user_id
      t.integer :edit_request_id
    end
  end
end
