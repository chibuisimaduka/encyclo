class AddIsManyToSubentities < ActiveRecord::Migration
  def change
    add_column :subentities, :is_many, :boolean
  end
end
