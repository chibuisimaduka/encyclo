class AddContentToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :content, :binary
  end

  def self.down
    remove_column :documents, :content
  end
end
