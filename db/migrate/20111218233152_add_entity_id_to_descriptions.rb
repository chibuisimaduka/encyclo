class AddEntityIdToDescriptions < ActiveRecord::Migration
  def self.up
    add_column :descriptions, :entity_id, :integer
  end

  def self.down
    remove_column :descriptions, :entity_id
  end
end
