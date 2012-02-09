class CreatePossibleDocumentTypes < ActiveRecord::Migration
  def change
    create_table :possible_document_types do |t|
      t.integer :document_id
      t.integer :document_type_id

      t.timestamps
    end
  end
end
