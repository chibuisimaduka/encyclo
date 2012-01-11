class RenameCategoryIdToTagIdForRankings < ActiveRecord::Migration
  def self.up
    rename_column :rankings, :category_id, :tag_id
  end

  def self.down
    rename_column :rankings, :tag_id, :category_id
  end
end
