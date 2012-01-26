class CreatePredicates < ActiveRecord::Migration
  def change
    create_table :predicates do |t|
      t.integer :component_id
      t.string :value

      t.timestamps
    end
  end
end
