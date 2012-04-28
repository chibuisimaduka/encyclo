class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.is_ip_address = false
    @user.home_entity = Entity.create({parent_id: entity_user.id, is_intermediate: false}, @user, Language::MAP[:universal], @user.email)
    if @user.save
      session[:user_id] = @user.id
      redirect_to :root, :notice => "Succesfully signed up!"
    else
      render "new"
    end
#    begin
#      User.transaction do
#        raise "invalid captcha" unless verify_recaptcha(:model => @user, :message => "Invalid capcha text input.")
#        @user.save!
#        if @user.home_entity.save
#          session[:user_id] = @user.id
#          redirect_to @user.home_entity, :notice => "Signed up! This is your home folder. Do whatever you want with it.\
#           But remember it is public.."
#        else
#          flash[:alert] = "An error has occured while creating the user home folder."
#          raise "Home entity not save!"
#        end
#      end
#    rescue
#      render "new"
#    end
  end

private
  def entity_user
    @entity ||= Entity.find(47281)
  end

end
