class Image < ActiveRecord::Base
  belongs_to :user, :inverse_of => :images
  belongs_to :entity, :inverse_of => :images

  has_many :ratings, :as => :rankable
  has_one :delete_request, :as => :destroyable

  mount_uploader :image, ImageUploader
  #mount_uploader :image, ImageUploader, :mount_as => :url

  validates_presence_of :entity_id
  validates_presence_of :user_id
  validates_presence_of :image

  #validates image format

  before_destroy :remove_image!
end
