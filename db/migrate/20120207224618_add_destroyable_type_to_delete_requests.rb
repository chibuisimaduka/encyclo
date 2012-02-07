class AddDestroyableTypeToDeleteRequests < ActiveRecord::Migration
  def change
    add_column :delete_requests, :destroyable_type, :string
  end
end
