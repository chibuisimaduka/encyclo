class User < ActiveRecord::Base

  attr_accessible :email, :password, :password_confirmation

  has_many :ratings

  has_many :entities, :inverse_of => :user

  attr_accessor :password
  before_save :encrypt_password

  validate :valid_password, :on => :create
  validates_confirmation_of :password

  validates_presence_of :email
  validates_uniqueness_of :email, :scope => :is_ip_address
  validates_inclusion_of :is_ip_address, :in => [false, true]
  
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

end
