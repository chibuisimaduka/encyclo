class CreateDocumentsEntitiesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :documents_entities, :id => false do |t|
      t.integer :document_id
      t.integer :entity_id
    end
  end

  def self.down
    drop_table :documents_entities
  end
end
