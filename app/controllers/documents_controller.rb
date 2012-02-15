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
    create_document(params[:document])
    respond_to do |format|
      format.html { redirect_to @entity }
      format.js
    end
  end

  def destroy
    @document = Document.find(params[:id], include: "entities")
    entity = @document.entities.first
    @document.destroy
    redirect_to entity
  end

private
  def create_document(doc_attrs)
	 @document = Document.new(doc_attrs)
    @document.user_id = current_user.id
    unless @document.local_document?
      if (doc = Document.find_by_source(@document.source))
        return doc if @entity.documents.include?(doc)
        @entity.documents << doc
        return @entity.save
      end
      processor = RemoteDocumentProcessor.new(@document).fetch
      # Check again for the source because it might have been redirected.
      if (doc = Document.find_by_source(@document.source))
        return doc if @entity.documents.include?(doc)
        @entity.documents << doc
        return @entity.save
      end
      @document.language_id = current_language.id
      processor.process
    end
    attrs = @document.attributes
    attrs.delete_if {|k,v| v.blank?}
    @entity.documents.create!(attrs)
  end

end
