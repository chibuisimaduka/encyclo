class CreateUserDocuments < ActiveRecord::Migration
  def change
    create_table :user_documents do |t|
      t.text :content

      t.timestamps
    end
  end
end
