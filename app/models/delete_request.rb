class DeleteRequest < ActiveRecord::Base

  attr_accessible #none

  belongs_to :entity, :inverse_of => :delete_request

  has_and_belongs_to_many :concurring_users, :class_name => "User", :join_table => "concurring_users_delete_requests"
  has_and_belongs_to_many :opposing_users, :class_name => "User", :join_table => "opposing_users_delete_requests" 

  validates_presence_of :entity_id

  validates_uniqueness_of :entity_id

  validate :consistent_users, :still_valid

private
  def consistent_users
    concurring_users.each do |u|
      if opposing_users.include?(u)
        errors.add(:concurring_users, "A using can't be concurring and opposing the deletion of an entity")
      end
    end
  end

  def still_valid
    unless concurring_users.length > 0
      errors.add(:concurring_users, "There is no one who wants to delete the entity anymore.")
    end
  end
end
