class CreateChildDocuments < ActiveRecord::Migration
  def change
    create_table :child_documents do |t|
      t.integer :parent_id
      t.integer :document_id

      t.timestamps
    end
  end
end
