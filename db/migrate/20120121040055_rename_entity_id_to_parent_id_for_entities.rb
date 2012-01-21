class RenameEntityIdToParentIdForEntities < ActiveRecord::Migration
  def up
    rename_column :entities, :entity_id, :parent_id
  end

  def down
    rename_column :entities, :parent_id, :entity_id
  end
end
