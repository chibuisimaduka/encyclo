class SessionsController < ApplicationController
  
  respond_to :html, :json

  def change_language
    if params[:current_language].blank? || params[:current_language][:id].blank? || (lang = (Language.find(params[:current_language][:id]) rescue nil)).blank?
      redirect_to :back, :notice => "Cannot change language: Invalid language given."
    else
      session[:current_language] = lang
      redirect_to :back
    end
  end

  def change_document_type_filter
    if params[:document_type_filter].blank? || params[:document_type_filter][:id].blank?
      session[:document_type_filter] = nil
      redirect_to :back
    elsif (doc_type = (DocumentType.find(params[:document_type_filter][:id]) rescue nil)).blank?
      redirect_to :back, :notice => "Cannot change document type: Invalid document type given."
    else
      session[:document_type_filter] = doc_type
      redirect_to :back
    end
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to :back, :notice => "Logged in!"
    else
      redirect_to :back, :notice => "Invalid email or password."
    end
  end

  def destroy
    session[:user_id] = nil
	 redirect_to :back, :notice => "Logged out!"
  end

end
