class AddRankableIdAndRankableTypeToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :rankable_id, :integer
    add_column :ratings, :rankable_type, :string
  end
end
