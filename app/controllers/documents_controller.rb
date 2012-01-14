class DocumentsController < ApplicationController

  def show
    @document = Document.find(params[:id])
  end

  def create
    @entity = Entity.find(params[:entity_id])
	 @document = @entity.documents.build(params[:document])
    # FIXME: create does not work.
    @document.fetch.process
    @entity.documents.create(@document.attributes)
	 redirect_to @entity
  end

end
