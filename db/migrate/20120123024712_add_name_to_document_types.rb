class AddNameToDocumentTypes < ActiveRecord::Migration
  def change
    add_column :document_types, :name, :string
  end
end
