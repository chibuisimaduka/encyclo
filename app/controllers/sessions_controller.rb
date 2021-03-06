class SessionsController < ApplicationController
  
  respond_to :html, :json

  def change_language
    if params[:current_language].blank? || params[:current_language][:id].blank? || (lang = (Language.find(params[:current_language][:id]) rescue nil)).blank?
      redirect_to :back, :alert => "Cannot change language: Invalid language given."
    else
      session[:current_language] = lang
      redirect_to :back
    end
  end

  def change_data_mode
    session[:data_mode] = !!params[:data_mode]
    redirect_to :back
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to :back, :notice => "Logged in!"
    else
      redirect_to :back, :alert => "Invalid email or password."
    end
  end

  def destroy
    session[:user_id] = nil
	 redirect_to :back, :notice => "Logged out!"
  end

end
