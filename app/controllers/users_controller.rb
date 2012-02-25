class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.is_ip_address = false
    @user.home_entity = Entity.create({parent_id: entity_user.id}, @user, current_language, @user.email)
    begin
      User.transaction do
        @user.save!
        if (begin @user.home_entity.recalculate_ancestors(true); true rescue false end)
          session[:user_id] = @user.id
          redirect_to root_path, :notice => "Signed up!"
        else
          flash[:alert] = "An error has occured while creating the user home folder."
          raise "Home entity not save!"
        end
      end
    rescue
      render "new"
    end
  end

private
  def entity_user
    @entity ||= Entity.find(51506)
  end

end
