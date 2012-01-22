class DropTableRankings < ActiveRecord::Migration
  def up
    drop_table :rankings
  end

  def down
    raise "FIXME"
  end
end
