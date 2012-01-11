class CreateEntitySimilarities < ActiveRecord::Migration
  def self.up
    create_table :entity_similarities do |t|
      t.integer :coefficient
      t.integer :entity_id
      t.integer :other_entity_id

      t.timestamps
    end
  end

  def self.down
    drop_table :entity_similarities
  end
end
