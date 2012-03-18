class RemoteDocumentsController < ApplicationController

  require 'remote_document_processor'
  include RemoteDocumentProcessor

  def create
    @entity = Entity.find(params[:entity_id]) if params[:entity_id]
    @remote_document = RemoteDocument.find_or_initialize_by_url(params[:url])
    unless @remote_document.url == params[:url]
      @remote_document = RemoteDocument.find_by_url(@remote_document.url) || @remote_document
    end
    if @remote_document.persisted?
      @entity.documents << doc unless @entity.documents.include?(@remote_document.document)
    else 
      @document = process_remote_document(@remote_document, params[:document] || {})
      @document.user_id = current_user.id
      @document.language_id = current_language.id
      unless @entity ? @entity.documents << @document : @document.save
        flash[:alert] = "An error has occured while creating the document."
      end
    end
    respond_to do |format|
      format.html {redirect_to :back}
      format.js
    end
  end

end
