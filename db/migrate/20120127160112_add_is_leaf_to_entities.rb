class AddIsLeafToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :is_leaf, :boolean
  end
end
