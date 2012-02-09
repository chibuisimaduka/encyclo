class PossibleDocumentTypesController < ApplicationController

  def create
    @document = Document.find(params[:document_id])
    @possible_document_type = @document.possible_document_types.find_or_create_by_document_type_id(params[:possible_document_type][:document_type_id])
    if (old_type = current_user.edit_requests.find_by_editable_type("PossibleDocumentType"))
      old_type.agreeing_users.delete(current_user)
      old_type.destroy unless old_type.valid?
    end
    if @possible_document_type.edit_request
      @possible_document_type.edit_request.agreeing_users << current_user unless @possible_document_type.edit_request.agreeing_users.include?(current_user)
    else
      @possible_document_type.create_edit_request(:agreeing_users => [current_user])
    end
  end

end
