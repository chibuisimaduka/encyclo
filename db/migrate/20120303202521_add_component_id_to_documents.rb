class AddComponentIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :component_id, :integer
  end
end
