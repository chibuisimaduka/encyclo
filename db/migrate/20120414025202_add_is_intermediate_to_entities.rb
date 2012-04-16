class AddIsIntermediateToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :is_intermediate, :boolean
  end
end
