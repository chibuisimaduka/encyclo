class RemoveTagIdFromTags < ActiveRecord::Migration
  def up
    remove_column :tags, :tag_id
  end

  def down
    add_column :tags, :tag_id, :integer
  end
end
