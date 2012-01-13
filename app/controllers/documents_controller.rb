class DocumentsController < ApplicationController

  def show
    @document = Document.find(params[:id])
  end

  def create
    @entity = Entity.find(params[:entity_id])
	 @document = @entity.documents.create(params[:document])
    @document.fetch.process.save!
	 redirect_to @entity
  end

end
