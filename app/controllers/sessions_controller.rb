class SessionsController < ApplicationController
  
  respond_to :html, :json

  def new
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
      redirect_to root_url, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
	 redirect_to root_url, :notice => "Logged out!"
  end

end
