class ComponentsController < ApplicationController

  def create
    @component = Component.new(params[:component])
    @component.user_id = current_user.id
    if !@component.save
      flash[:notice] = "An error has occured while creating component"
    end
    redirect_to :back
  end

end
