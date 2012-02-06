class AddNestedEntityIdToAssociationDefinitions < ActiveRecord::Migration
  def change
    add_column :association_definitions, :nested_entity_id, :integer
  end
end
