class PossibleDocumentTypesController < ApplicationController

  def create
    @document = Document.find(params[:document_id])
    @possible_document_type = @document.possible_document_types.find_by_document_type_id(params[:possible_document_type][:document_type_id])
    if @possible_document_type
      raise "TODO"
      @possible_document_type
    else
      @possible_document_type = @document.possible_document_types.create(params[:possible_document_type])
    end
    redirect_to :back
  end

end
