class AddContentSizeRankToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :content_size_rank, :float
  end
end
