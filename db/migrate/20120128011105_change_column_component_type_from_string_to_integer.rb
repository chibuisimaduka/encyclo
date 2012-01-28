class ChangeColumnComponentTypeFromStringToInteger < ActiveRecord::Migration
  def change
    remove_column :components, :component_type
    add_column :components, :component_type, :integer
  end
end
