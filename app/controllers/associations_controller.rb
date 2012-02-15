class AssociationsController < ApplicationController
  
  def create
    @association = Association.new(params[:association])
    @association.user_id = current_user.id
    if !@association.save
      flash[:notice] = "Error while creating association"
    end
    redirect_to :back
  end

end
