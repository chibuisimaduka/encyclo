class CreateNames < ActiveRecord::Migration
  def change
    create_table :names do |t|
      t.string :value
      t.integer :language_id
      t.integer :entity_id

      t.timestamps
    end
  end
end
