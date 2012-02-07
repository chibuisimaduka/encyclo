class AddDestroyableIdToDeleteRequests < ActiveRecord::Migration
  def change
    add_column :delete_requests, :destroyable_id, :integer
  end
end
