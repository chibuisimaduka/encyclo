class DeleteDeprecatedTables < ActiveRecord::Migration
  def change
    drop_table :components
    drop_table :predicates
    drop_table :tags
    drop_table :entities_tags
    drop_table :images_tags
  end
end
