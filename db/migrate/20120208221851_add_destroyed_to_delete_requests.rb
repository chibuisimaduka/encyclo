class AddDestroyedToDeleteRequests < ActiveRecord::Migration
  def change
    add_column :delete_requests, :destroyed, :boolean
  end
end
