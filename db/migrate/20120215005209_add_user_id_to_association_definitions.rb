class AddUserIdToAssociationDefinitions < ActiveRecord::Migration
  def change
    add_column :association_definitions, :user_id, :integer
  end
end
