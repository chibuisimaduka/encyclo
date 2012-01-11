class AddTagIdToEntities < ActiveRecord::Migration
  def self.up
    add_column :entities, :tag_id, :integer
  end

  def self.down
    remove_column :entities, :tag_id
  end
end
