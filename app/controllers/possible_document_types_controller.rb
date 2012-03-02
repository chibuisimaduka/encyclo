class PossibleDocumentTypesController < ApplicationController

  def create
    @document = Document.find(params[:document_id])
    @possible_document_type = @document.possible_document_types.find_or_initialize_by_document_type_id(params[:possible_document_type][:document_type_id])
    EditRequest.update(@possible_document_type, @document.possible_document_types, current_user)
    unless @document.possible_document_types.include?(@possible_document_type)
      @document.possible_document_types << @possible_document_type 
    end
  end

end
