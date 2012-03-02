class CreateRemoteDocuments < ActiveRecord::Migration
  def change
    create_table :remote_documents do |t|
      t.string :url
      t.binary :content

      t.timestamps
    end
  end
end
