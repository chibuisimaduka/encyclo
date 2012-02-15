class AddUserIdToAssociations < ActiveRecord::Migration
  def change
    add_column :associations, :user_id, :integer
  end
end
