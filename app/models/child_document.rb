class ChildDocument < ActiveRecord::Base
  belongs_to :parent, :class_name => "Document"
  validates_presence_of :parent

  belongs_to :document
  validates_presence_of :document
end
