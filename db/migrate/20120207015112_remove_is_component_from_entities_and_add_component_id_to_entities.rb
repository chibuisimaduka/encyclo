class RemoveIsComponentFromEntitiesAndAddComponentIdToEntities < ActiveRecord::Migration
  def change
    remove_column :entities, :is_component
    add_column :entities, :component_id, :integer
  end
end
