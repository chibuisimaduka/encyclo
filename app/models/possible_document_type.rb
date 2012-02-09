class PossibleDocumentType < ActiveRecord::Base
  belongs_to :document, :inverse_of => :possible_document_types
  belongs_to :document_type, :inverse_of => :possible_documents

  has_one :delete_request, :as => :detroyable

  validates_presence_of :document_id
  validates_presence_of :document_type_id

  validates_uniqueness_of :document_type_id, :scope => :document_id
end
