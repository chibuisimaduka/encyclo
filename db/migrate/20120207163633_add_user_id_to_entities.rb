class AddUserIdToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :user_id, :integer
  end
end
