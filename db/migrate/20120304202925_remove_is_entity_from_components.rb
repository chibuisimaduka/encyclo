class RemoveIsEntityFromComponents < ActiveRecord::Migration
  def up
    remove_column :components, :is_entity
  end

  def down
    add_column :components, :is_entity, :boolean
  end
end
