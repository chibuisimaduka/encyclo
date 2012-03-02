class RemoteDocumentsController < ApplicationController

  include RemoteDocumentProcessor

  def create
    @entity = Entity.find(params[:entity_id])
    @remote_document = RemoteDocument.find_or_initialize_by_url(params[:url])
    unless @remote_document.url == parmas[:url]
      @remote_document = RemoteDocument.find_by_url(@remote_document.url) || @remote_document
    end
    if @remote_document.persisted?
      @entity.documents << doc unless @entity.documents.include?(@remote_document.document)
    else
      @document = process(@remote_document)
      @document.user_id = current_user.id
      @document.language_id = current_language.id
      begin @entity.save && @document.save rescue # Not even sure if this throws an exception
        flash[:alert] = "An error has occured while creating the document."
      end
    end
    respond_to do |format|
      format.html {redirect_to @entity}
      format.js
    end
  end

end
