class DeleteRequest < ActiveRecord::Base

  attr_accessible #none

  belongs_to :destroyable, :inverse_of => :delete_request, :polymorphic => true
  validates_presence_of :destroyable

  has_and_belongs_to_many :concurring_users, :class_name => "User", :join_table => "concurring_users_delete_requests"
  has_and_belongs_to_many :opposing_users, :class_name => "User", :join_table => "opposing_users_delete_requests" 

  validates_uniqueness_of :destroyable_id, :scope => :destroyable_type

  validate :consistent_users, :still_valid

  validates_inclusion_of :considered_destroyed, :in => [true, false]

  def considered_deleted?
    concurring_users.length - opposing_users.length > 3
  end

  def self.alive_scope(destroyables, user=nil)
    return destroyables if destroyables.blank?
    alives = destroyables.where("#{destroyables.table_name}.id NOT IN (SELECT destroyable_id FROM delete_requests WHERE destroyable_type = '#{destroyables.model_name}' AND considered_destroyed = TRUE)")
    alives.joins("LEFT JOIN delete_requests ON #{destroyables.table_name}.id = delete_requests.destroyable_id AND delete_requests.destroyable_type = '#{destroyables.model_name}'")
      .where("(delete_requests.id IS NULL) OR (? NOT IN (SELECT user_id FROM concurring_users_delete_requests WHERE delete_request_id = delete_requests.id))", user.id) if user
  end

  def self.alive?(destroyable)
    return false unless destroyable.delete_request
    destroyable.delete_request.concurring_users.include?(current_user) || (!destroyable.delete_request.opposing_users.include?(current_user) &&
      (destroyable.delete_request.concurring_users.length - destroyable.delete_request.opposing_users.length) > 3)
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
