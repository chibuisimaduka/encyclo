class AddComponentTypeIdToComponents < ActiveRecord::Migration
  def change
    add_column :components, :component_type_id, :integer
  end
end
