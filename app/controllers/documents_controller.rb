class DocumentsController < ApplicationController

  respond_to :html, :json

  def new
    @document = Document.new
    @entity = Entity.find(params[:entity_id]) if params[:entity_id]
  end

  def show
    @document = Document.find(params[:id])
  end

  #def update
  #  @document = Document.find(params[:id])
  #  @document.update_attributes(params[:document])
  #  respond_with @document
  #end

  def create
    @entity = Entity.find(params[:entity_id])
    if !create_document(params[:document])
      flash[:notice] = "Error while creating the document. #{@document.errors.full_messages.join("\n")}"
      respond_to do |format|
        format.html { render action: "new" }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to @entity }
        format.js
      end
    end
  end

private
  require 'remote_document_processor'

  def create_document(doc_attrs)
	 @document = @entity.documents.build(doc_attrs)
    @document.user_id = current_user.id
    unless @document.local_document?
      if (doc = Document.find_by_source(@document.source))
        return true if @entity.documents.include?(doc)
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
    # OPTIMIZE: I really don't understand rails sometimes..(often)
    @entity.save ? @document.save : false
  end

end
