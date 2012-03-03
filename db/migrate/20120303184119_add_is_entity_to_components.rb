class AddIsEntityToComponents < ActiveRecord::Migration
  def change
    add_column :components, :is_entity, :boolean
  end
end
