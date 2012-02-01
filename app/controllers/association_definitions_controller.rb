class AssociationDefinitionsController < ApplicationController

  respond_to :html, :json

  def update
    @association_definition = AssociationDefinition.find(params[:id])
    @association_definition.update_attributes(params[:association_definition])
    respond_with @association_definition
  end

  def create
    @association_definition = AssociationDefinition.new(params[:association_definition])
    @association_definition.save!
    redirect_to :back
  end

  def destroy
    @association_definition = AssociationDefinition.find(params[:id])
    @association_definition.destroy
    redirect_to :back
  end

end
