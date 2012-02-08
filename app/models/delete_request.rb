class DeleteRequest < ActiveRecord::Base

  attr_accessible #none

  belongs_to :destroyable, :inverse_of => :delete_request, :polymorphic => true

  has_and_belongs_to_many :concurring_users, :class_name => "User", :join_table => "concurring_users_delete_requests"
  has_and_belongs_to_many :opposing_users, :class_name => "User", :join_table => "opposing_users_delete_requests" 

  validates_presence_of :destroyable_id
  validates_uniqueness_of :destroyable_id, :scope => :destroyable_type

  validate :consistent_users, :still_valid

  def considered_deleted?
    #concurring_users.include?(current_user) || (!destroyable.delete_request.opposing_users.include?(current_user) &&
    concurring_users.length - opposing_users.length > 3
  end

  def self.alive_scope(destroyables, user=nil)
    if user
      destroyables.joins(:delete_request => :concurring_users).where("delete_requests.destroyed = FALSE OR concurring_users_delete_requests.user_id = ?", user.id)
    else
      destroyables.joins(:delete_request).where("delete_requests.destroyed = FALSE")
    end
  end

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
