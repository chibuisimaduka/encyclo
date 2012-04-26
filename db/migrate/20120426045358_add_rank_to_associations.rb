class AddRankToAssociations < ActiveRecord::Migration
  def change
    add_column :associations, :rank, :float
  end
end
