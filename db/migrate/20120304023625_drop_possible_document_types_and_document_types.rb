class DropPossibleDocumentTypesAndDocumentTypes < ActiveRecord::Migration
  def change
    drop_table :possible_document_types
    drop_table :document_types
  end
end
