class RemoveDestroyedFromDeleteRequests < ActiveRecord::Migration
  def change
    remove_column :delete_requests, :destroyed
  end
end
