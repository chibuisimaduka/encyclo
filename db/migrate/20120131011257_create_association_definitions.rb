class CreateAssociationDefinitions < ActiveRecord::Migration
  def change
    create_table :association_definitions do |t|
      t.integer :entity_id
      t.integer :associated_entity_id
      t.boolean :entity_is_many
      t.boolean :associated_entity_is_many

      t.timestamps
    end
  end
end
