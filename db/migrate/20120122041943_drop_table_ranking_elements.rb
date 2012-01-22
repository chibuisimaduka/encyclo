class DropTableRankingElements < ActiveRecord::Migration
 
  def up
    drop_table :ranking_elements
  end

  def down
    raise "FIXME"
  end
end
