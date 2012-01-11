class AddNumVotesToEntities < ActiveRecord::Migration
  def self.up
    add_column :entities, :num_votes, :integer, :default => 0
  end

  def self.down
    remove_column :entities, :num_votes
  end
end
