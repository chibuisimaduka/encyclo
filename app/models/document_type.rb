class DocumentType < ActiveRecord::Base
  has_many :possible_documents, :class_name => "PossibleDocumentType", :inverse_of => :document_type, :dependent => :destroy

  validates_presence_of :name

  ALL = DocumentType.all.sort_by(&:name)
end
