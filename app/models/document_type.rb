class DocumentType < ActiveRecord::Base
  has_many :documents

  validates_presence_of :name

  ALL = DocumentType.all.sort_by(&:name)
end
