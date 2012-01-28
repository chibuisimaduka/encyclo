class AddValueToPredicateItems < ActiveRecord::Migration
  def change
    add_column :predicate_items, :value, :string
  end
end
