class DeleteRequest < ActiveRecord::Base
  belongs_to :entity
  belongs_to :user

  has_and_belongs_to_many :concurring_users, :class_name => "User", :join_table => "concurring_users_delete_requests"
  has_and_belongs_to_many :opposing_users, :class_name => "User", :join_table => "opposing_users_delete_requests" 

  validates_presence_of :entity_id
  validates_presence_of :user_id
end
