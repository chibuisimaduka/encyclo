class Language < ActiveRecord::Base
  has_many :documents
  has_many :names, :inverse_of => :language

  ALL = Language.all.sort_by(&:name)
end
