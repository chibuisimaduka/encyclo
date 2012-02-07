class CreateOpposingUsersDeleteRequests < ActiveRecord::Migration
  def change
    create_table :opposing_users_delete_requests, :id => false do |t|
      t.integer :user_id
      t.integer :delete_request_id
    end
  end
end
