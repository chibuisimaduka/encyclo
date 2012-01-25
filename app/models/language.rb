class Language < ActiveRecord::Base
  has_many :documents
  has_many :names
end
