class CreatePredicateItems < ActiveRecord::Migration
  def change
    create_table :predicate_items do |t|
      t.integer :predicate_id

      t.timestamps
    end
  end
end
