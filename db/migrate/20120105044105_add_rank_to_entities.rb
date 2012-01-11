class AddRankToEntities < ActiveRecord::Migration
  def self.up
    add_column :entities, :rank, :float
  end

  def self.down
    remove_column :entities, :rank
  end
end
