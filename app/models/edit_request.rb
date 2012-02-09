class EditRequest < ActiveRecord::Base
  belongs_to :editable, :polymorphic => true, :dependent => :destroy
  has_and_belongs_to_many :agreeing_users, :class_name => "User", :join_table => "users_edit_requests"

  validate :has_agreeing_users, :consistent_users

  validates_presence_of :editable_id
  validates_presence_of :editable_type

private
  def consistent_users
    agreeing_users.includes(:edit_requests => :agreeing_users).each do |user|
      unless (user.edit_requests.joins(:agreeing_users).where("users.id = ?", user.id) - [self]).blank?
        errors.add(:agreeing_users, "#{user.email} is inconsistent. He agrees for two document types.")
      end
    end
  end

  def has_agreeing_users
    unless agreeing_users.length > 0
      errors.add(:agreeing_users, "must have at least one.")
    end
  end
end
