class CreateFreebaseEntities < ActiveRecord::Migration
  def change
    create_table :freebase_entities do |t|
      t.string :freebase_id
      t.string :freebase_type

      t.timestamps
    end
  end
end
