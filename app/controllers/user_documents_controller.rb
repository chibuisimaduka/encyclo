class UserDocumentsController < ApplicationController

  respond_to :html, :json
  
  def new
    redirect_to :back, :alert => "You must be logged in to create a document.." if current_user.is_ip_address?
    @document = Document.new
    @entity = Entity.find(params[:entity_id]) if params[:entity_id]
  end

  def update
    @user_document = UserDocument.find(params[:id])
    @user_document.update_attributes(params[:user_document])
    respond_with @user_document
  end

  def create
    @entity = Entity.find(params[:entity_id]) if params[:entity_id]
    @document = Document.create(params[:document])
    @document.documentable = UserDocument.new(params[:user_document])
    @document.set_document_type_id(params[:document_type_id], current_user)
    @document.user_id = current_user.id
    @document.language_id = current_language.id
    unless @entity ? @entity.documents << @document : @document.save
      flash[:alert] = "Error while creating the document. #{@document.errors.full_messages.join("\n")}"
      render action: "new"
    else
       redirect_to @entity ? @entity : :back
    end
  end

end
