class AddIsAboutToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :is_about, :boolean
  end
end
