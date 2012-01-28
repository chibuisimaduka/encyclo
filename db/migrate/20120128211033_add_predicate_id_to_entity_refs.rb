class AddPredicateIdToEntityRefs < ActiveRecord::Migration
  def change
    add_column :entity_refs, :predicate_id, :integer
  end
end
