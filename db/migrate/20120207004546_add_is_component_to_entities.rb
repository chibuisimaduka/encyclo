class AddIsComponentToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :is_component, :boolean
  end
end
