class AddIsManyToComponents < ActiveRecord::Migration
  def change
    add_column :components, :is_many, :boolean
  end
end
