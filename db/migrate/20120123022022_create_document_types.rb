class CreateDocumentTypes < ActiveRecord::Migration
  def change
    create_table :document_types do |t|

      t.timestamps
    end
  end
end
