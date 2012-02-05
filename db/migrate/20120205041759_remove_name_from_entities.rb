class RemoveNameFromEntities < ActiveRecord::Migration
  def change
    remove_column :entities, :name
  end
end
