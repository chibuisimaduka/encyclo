class AddRankToImages < ActiveRecord::Migration
  def change
    add_column :images, :rank, :float
  end
end
