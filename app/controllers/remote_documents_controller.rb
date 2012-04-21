class RemoteDocumentsController < ApplicationController

  def create
    @entity = Entity.find(params[:entity_id]) if params[:entity_id]
    unless RemoteDocument.create_document(@entity, params[:url], params[:document], current_user, current_language)
      flash[:alert] = "An error has occured while creating the document."
    end
    respond_to do |format|
      format.html {redirect_to :back}
      format.js
    end
  end

end
