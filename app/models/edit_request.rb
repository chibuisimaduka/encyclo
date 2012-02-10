class EditRequest < ActiveRecord::Base
  belongs_to :editable, :polymorphic => true, :dependent => :destroy
  has_and_belongs_to_many :agreeing_users, :class_name => "User", :join_table => "users_edit_requests"

  validate :has_agreeing_users, :consistent_users

  validates_presence_of :editable_id
  validates_presence_of :editable_type

  def self.user_editable(editables, user)
    editables.joins(:edit_request => :agreeing_users).where("users.id = ?", user.id).first
  end

  def self.probable_editable(editables, user)
    user_editable(editables, user) || most_agreed_editable(editables)
  end

  def self.most_agreed_editable(editables)
    editables_map = Hash[editables.includes(:edit_request => :agreeing_users).map{|t| [t, t.edit_request.agreeing_users.length]}]
    (editables_map.sort_by{|k,v| v}).last[0] unless editables_map.blank?
  end

  def self.update(editable, user)
    if (old_type = user.edit_requests.find_by_editable_type(editable.class.name))
      old_type.agreeing_users.delete(user)
      old_type.destroy unless old_type.valid?
    end
    if editable.edit_request
      editable.edit_request.agreeing_users << user unless editable.edit_request.agreeing_users.include?(user)
    else
      editable.create_edit_request(:agreeing_users => [user])
    end
  end

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
