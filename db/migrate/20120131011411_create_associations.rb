class CreateAssociations < ActiveRecord::Migration
  def change
    create_table :associations do |t|
      t.integer :association_definition_id
      t.integer :entity_id
      t.integer :associated_entity_id

      t.timestamps
    end
  end
end
