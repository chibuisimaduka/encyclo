class SessionsController < ApplicationController
  
  respond_to :html, :json

  def change_language
    if params[:current_language].blank? || params[:current_language][:id].blank? || (lang = Language.find(params[:current_language][:id])).blank?
      redirect_to :back, :notice => "Cannot change language: Invalid language given."
    else
      session[:current_language] = lang
      redirect_to :back
    end
  end

  def update
    value = params[params[:value_key]]
    session[params[:session_key]].update_attributes value
    respond_with value
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
