class AddEntityIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :entity_id, :integer
  end
end
