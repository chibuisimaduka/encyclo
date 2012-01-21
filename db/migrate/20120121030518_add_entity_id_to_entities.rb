class AddEntityIdToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :entity_id, :integer
  end
end
