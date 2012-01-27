class CreateSubentities < ActiveRecord::Migration
  def change
    create_table :subentities do |t|
      t.integer :entity_id
      t.string :name

      t.timestamps
    end
  end
end
