class PossibleDocumentTypesController < ApplicationController

  def create
    @document = Document.find(params[:document_id])
    @possible_document_type = @document.possible_document_types.find_or_create_by_document_type_id(params[:possible_document_type][:document_type_id])
    EditRequest.update(@possible_document_type, @possible_document_type.document.possible_document_types, current_user)
  end

end
