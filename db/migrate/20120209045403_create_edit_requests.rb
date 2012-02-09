class CreateEditRequests < ActiveRecord::Migration
  def change
    create_table :edit_requests do |t|
      t.integer :editable_id
      t.string :editable_name

      t.timestamps
    end
  end
end
