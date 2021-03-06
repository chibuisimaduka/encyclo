class AssociationDefinitionsController < ApplicationController

  #respond_to :html, :json

  #def update
  #  @association_definition = AssociationDefinition.find(params[:id])
  #  @association_definition.update_attributes(params[:association_definition])
  #  respond_with @association_definition
  #end

  def create
    @association_definition = AssociationDefinition.new(params[:association_definition])
    @association_definition.user_id = current_user.id
    if !@association_definition.save
      flash[:alert] = "Error while creating the association definition."
    end
    redirect_to :back
  end

end
