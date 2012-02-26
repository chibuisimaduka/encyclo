class User < ActiveRecord::Base

  attr_accessible :email, :password, :password_confirmation

  has_many :ratings, :inverse_of => :user, :dependent => :destroy

  # ======= USER CREATIONS =======
  has_many :entities, :inverse_of => :user, :dependent => :destroy
  has_many :documents, :inverse_of => :user, :dependent => :destroy
  has_many :associations, :inverse_of => :user, :dependent => :destroy
  has_many :association_definitions, :inverse_of => :user, :dependent => :destroy
  has_many :components, :inverse_of => :user, :dependent => :destroy
  has_many :images, :inverse_of => :user, :dependent => :destroy
  # ==== END USER CREATIONS ====

  belongs_to :home_entity, :class_name => "Entity", :inverse_of => :home_user, :dependent => :destroy
  # AFAIK, we cannot validate that this since the entity validates that it has a user. It is circular..
  # validates_presence_of :home_entity

  attr_accessor :password
  before_save :encrypt_password

  validate :valid_password, :on => :create
  validates_confirmation_of :password

  validates_presence_of :email
  validates_uniqueness_of :email, :scope => :is_ip_address
  validates_inclusion_of :is_ip_address, :in => [false, true]

  has_and_belongs_to_many :concurring_delete_requests, :class_name => "DeleteRequest", :join_table => "concurring_users_delete_requests"
  has_and_belongs_to_many :opposing_delete_requests, :class_name => "DeleteRequest", :join_table => "opposing_users_delete_requests"
  
  has_and_belongs_to_many :edit_requests, :join_table => "users_edit_requests"

  before_destroy :destroy_invalid_associations
  
  validate :valid_password

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
		self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
	 end
  end
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

private
  def valid_password
    unless is_ip_address
      validates_presence_of :password
    end
  end

  def destroy_invalid_associations
    # OPTIMIZE: There is got to be a better way..
    edit_requests.each do |e|
      e.agreeing_users.delete(self)
      e.destroy unless e.valid?
    end
    concurring_delete_requests.each do |d|
      d.concurring_users.delete(self)
      d.destroy unless d.valid?
    end
    opposing_delete_requests.each do |o|
      o.opposing_users.delete(self)
      o.update_attributes(:considered_destroyed => true) if o.considered_deleted?
    end
  end

end
