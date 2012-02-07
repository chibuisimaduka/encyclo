class RemoveEntityIdFromDeleteRequests < ActiveRecord::Migration
  def change
    remove_column :delete_requests, :entity_id
  end
end
