class AddNameToFreebaseEntities < ActiveRecord::Migration
  def change
    add_column :freebase_entities, :name, :string
  end
end
