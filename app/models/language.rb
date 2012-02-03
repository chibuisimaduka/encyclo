class Language < ActiveRecord::Base
  has_many :documents
  has_many :names, :inverse_of => :language
end
