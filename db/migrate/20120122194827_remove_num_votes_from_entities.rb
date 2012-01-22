class RemoveNumVotesFromEntities < ActiveRecord::Migration
  def up
    remove_column :entities, :num_votes
  end

  def down
    add_column :ratings, :num_votes, :integer
  end
end
