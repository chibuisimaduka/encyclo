class AddEntityIdToEntityRefs < ActiveRecord::Migration
  def change
    add_column :entity_refs, :entity_id, :integer
  end
end
