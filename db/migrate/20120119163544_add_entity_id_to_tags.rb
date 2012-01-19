class AddEntityIdToTags < ActiveRecord::Migration
  def change
    add_column :tags, :entity_id, :integer
  end
end
