class AddDocumentableIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :documentable_id, :integer
  end
end
