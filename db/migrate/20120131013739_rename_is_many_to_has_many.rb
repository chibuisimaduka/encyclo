class RenameIsManyToHasMany < ActiveRecord::Migration
  def change
    rename_column :association_definitions, :entity_is_many, :entity_has_many
    rename_column :association_definitions, :associated_entity_is_many, :associated_entity_has_many
  end
end
