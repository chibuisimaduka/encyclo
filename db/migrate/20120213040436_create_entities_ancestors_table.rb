class CreateEntitiesAncestorsTable < ActiveRecord::Migration
  def change
    create_table :entities_ancestors, :id => false do |t|
      t.integer :entity_id
      t.integer :ancestor_id
    end
  end
end
