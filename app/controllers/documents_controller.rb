class DocumentsController < ApplicationController

  def index
    @entity = Entity.find(params[:entity_id])
    raise "FIXME: PrettyPrinter entities"
    @printer = PrettyPrinter.new(@entity)
  end

  def show
    @document = Document.find(params[:id])
    if @document.documentable_type == 'RemoteDocument'
      redirect_to @document.documentable.url
    end
  end

end
