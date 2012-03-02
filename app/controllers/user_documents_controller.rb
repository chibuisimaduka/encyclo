class UserDocumentsController < ApplicationController
  
  def new
    redirect_to :back, :alert => "You must be logged in to create a document.." if current_user.is_ip_address?
    @document = Document.new
    @entity = Entity.find(params[:entity_id]) if params[:entity_id]
  end

  def create
    @document.user_id = current_user.id
    @document.language_id = current_language.id
    if !create_document(params[:document])
      flash[:alert] = "Error while creating the document. #{@document.errors.full_messages.join("\n")}"
      render action: "new"
    else
       redirect_to @entity
    end
  end

end
