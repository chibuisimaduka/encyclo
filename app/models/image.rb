class Image < ActiveRecord::Base
  attr_accessible :remote_image_url
  
  belongs_to :entity

  has_many :ratings, :as => :rankable

  mount_uploader :image, ImageUploader
  #mount_uploader :image, ImageUploader, :mount_as => :url

  validates_presence_of :image

  #validates image format

  before_destroy :remove_image!
end
