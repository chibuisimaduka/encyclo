class UserDocument < ActiveRecord::Base

  has_one :document, :as => :documentable
  validates_presence_of :document

  validates_presence_of :content

end
