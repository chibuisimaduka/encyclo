class AddConsideredDestroyedToDeleteRequests < ActiveRecord::Migration
  def change
    add_column :delete_requests, :considered_destroyed, :boolean
  end
end
