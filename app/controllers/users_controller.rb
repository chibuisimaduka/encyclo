class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.is_ip_address = false
	 if @user.save
        session[:user_id] = @user.id
		 redirect_to root_path, :notice => "Signed up!"
    else
      render "new"
    end
  end

end
