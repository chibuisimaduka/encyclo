class CreateConcurringUsersDeleteRequests < ActiveRecord::Migration
  def change
    create_table :concurring_users_delete_requests, :id => false do |t|
      t.integer :user_id
      t.integer :delete_request_id
    end
  end
end
