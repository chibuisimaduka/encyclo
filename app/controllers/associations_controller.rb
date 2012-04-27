class AssociationsController < ApplicationController

  def index
    respond_to do |format|
      format.html do
        redirect_to params.merge(controller: :entities, action: :show)
      end
      format.js do
        @entity = Entity.find(params[:entity_id])
        @definition = AssociationDefinition.find(params[:definition_id])
      end
    end
  end
  
  def create
    @association = Association.new(params[:association])
    @association.user_id = current_user.id
    if !@association.save
      flash[:alert] = "Error while creating association"
    end
    redirect_to :back
  end

end
