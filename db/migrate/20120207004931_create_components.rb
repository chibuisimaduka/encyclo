class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.integer :entity_id
      t.integer :associated_entity_id

      t.timestamps
    end
  end
end
