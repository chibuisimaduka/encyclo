class CreateEntityRefs < ActiveRecord::Migration
  def change
    create_table :entity_refs do |t|
      t.string :name

      t.timestamps
    end
  end
end
