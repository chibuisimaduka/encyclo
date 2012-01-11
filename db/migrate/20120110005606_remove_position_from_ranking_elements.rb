class RemovePositionFromRankingElements < ActiveRecord::Migration
  def self.up
    remove_column :ranking_elements, :position
  end

  def self.down
    add_column :ranking_elements, :position, :integer
  end
end
