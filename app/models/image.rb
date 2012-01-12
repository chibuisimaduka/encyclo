class Image < ActiveRecord::Base
  belongs_to :entity
  mount_uploader :image, ImageUploader
end
