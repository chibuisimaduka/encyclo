class AssociationsController < ApplicationController
  respond_to :html, :json
  
  def update
    @association = Predicate.find_or_create_by_component_id_and_entity_id(params[:component_id], params[:entity_id])
    @association.add_value(params[:index].to_i, params[:association][:"value_#{params[:index]}"])
    @association.save
    respond_with @association
  end

  def create
    @association = Association.new(params[:association])
    @association.save!
    redirect_to :back
  end

  def destroy
    @association = Association.find(params[:id])
    @association.destroy
    redirect_to :back
  end

end
