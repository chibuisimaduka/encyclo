class Image < ActiveRecord::Base
  attr_accessible :remote_image_url
  belongs_to :entity
  mount_uploader :image, ImageUploader
  #mount_uploader :image, ImageUploader, :mount_as => :url

  validates_presence_of :image

  before_destroy :remove_image!
end
