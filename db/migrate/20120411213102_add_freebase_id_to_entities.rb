class AddFreebaseIdToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :freebase_id, :string
  end
end
