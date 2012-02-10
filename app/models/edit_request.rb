class EditRequest < ActiveRecord::Base
  belongs_to :editable, :polymorphic => true, :dependent => :destroy
  has_and_belongs_to_many :agreeing_users, :class_name => "User", :join_table => "users_edit_requests"

  validate :has_agreeing_users

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

  def self.update(editable, editables, user)
    deprecated_editables = editables.joins(:edit_request => :agreeing_users).where("users.id = ?", user.id) - [editable]
    unless deprecated_editables.blank?
      deprecated_editables.each do |e|
        e.edit_request.agreeing_users.delete(user)
        e.edit_request.destroy unless e.edit_request.valid?
      end
    end
    if editable.edit_request
      editable.edit_request.agreeing_users << user unless editable.edit_request.agreeing_users.include?(user)
    else
      editable.create_edit_request(:agreeing_users => [user])
    end
  end

private
  def has_agreeing_users
    unless agreeing_users.length > 0
      errors.add(:agreeing_users, "must have at least one.")
    end
  end
end
