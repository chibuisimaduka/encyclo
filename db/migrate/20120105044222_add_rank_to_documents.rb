class AddRankToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :rank, :float
  end

  def self.down
    remove_column :documents, :rank
  end
end
