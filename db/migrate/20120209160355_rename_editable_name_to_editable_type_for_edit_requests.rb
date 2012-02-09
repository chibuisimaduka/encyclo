class RenameEditableNameToEditableTypeForEditRequests < ActiveRecord::Migration
  def change
    rename_column :edit_requests, :editable_name, :editable_type
  end
end
