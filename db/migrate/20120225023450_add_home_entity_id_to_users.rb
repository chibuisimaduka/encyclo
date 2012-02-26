class AddHomeEntityIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :home_entity_id, :integer
  end
end
