class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :entity_id
      t.integer :user_id
      t.float :value

      t.timestamps
    end
  end
end
