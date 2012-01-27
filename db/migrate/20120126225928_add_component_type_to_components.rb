class AddComponentTypeToComponents < ActiveRecord::Migration
  def change
    add_column :components, :component_type, :string
  end
end
