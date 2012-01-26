class AddEntityIdToPredicates < ActiveRecord::Migration
  def change
    add_column :predicates, :entity_id, :integer
  end
end
