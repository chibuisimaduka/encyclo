class PossibleDocumentType < ActiveRecord::Base
  belongs_to :document, :inverse_of => :possible_document_types
  validates_presence_of :document

  belongs_to :document_type, :inverse_of => :possible_documents
  validates_presence_of :document_type

  has_one :edit_request, :as => :editable

  validates_uniqueness_of :document_type_id, :scope => :document_id
end
