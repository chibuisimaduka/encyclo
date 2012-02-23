class Image < ActiveRecord::Base

  attr_protected :user_id, :user

  belongs_to :user, :inverse_of => :images
  validates_presence_of :user

  belongs_to :entity, :inverse_of => :images
  validates_presence_of :entity

  has_many :ratings, :as => :rankable, :dependent => :destroy
  has_one :delete_request, :as => :destroyable, :dependent => :destroy

  mount_uploader :image, ImageUploader
  #mount_uploader :image, ImageUploader, :mount_as => :url

  validates_presence_of :image

  #validates image format

  before_destroy :remove_image!

  self.per_page = 5
end
