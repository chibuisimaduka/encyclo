class DocumentsController < ApplicationController

  respond_to :html, :json

  require 'remote_document_processor'

  def new
    @document = Document.new
    @entity = Entity.find(params[:entity_id]) if params[:entity_id]
  end

  def show
    @document = Document.find(params[:id])
  end

  def update
    @document = Document.find(params[:id])
    @document.update_attributes(params[:document])
    respond_with @document
  end

  def create
    @entity = Entity.find(params[:entity_id])
	 @document = @entity.documents.build(params[:document])
    RemoteDocumentProcessor.new(@document).fetch.process unless @document.local_document?
    attrs = @document.attributes
    attrs.delete_if {|k,v| v.blank?}
    @entity.documents.create!(attrs)
	 redirect_to @entity
  end

  def destroy
    @document = Document.find(params[:id], include: "entities")
    entity = @document.entities.first
    @document.destroy
    redirect_to entity
  end

end
