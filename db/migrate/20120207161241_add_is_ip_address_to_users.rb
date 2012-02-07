class AddIsIpAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_ip_address, :boolean
  end
end
