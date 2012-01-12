class Document < ActiveRecord::Base
  has_and_belongs_to_many :entities
  validates_presence_of :source
end
