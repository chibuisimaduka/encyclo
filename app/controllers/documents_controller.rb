class DocumentsController < ApplicationController

  respond_to :html, :json

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
    @document.fetch.process
    attrs = @document.attributes
    attrs.delete_if {|k,v| v.blank?}
    @entity.documents.create!(attrs)
	 redirect_to @entity
  end

end
