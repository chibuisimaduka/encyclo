class AddDocumentableTypeToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :documentable_type, :string
  end
end
