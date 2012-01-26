class PredicatesController < ApplicationController
  respond_to :html, :json
  
  def update
    @predicate = Predicate.find_or_create_by_component_id_and_entity_id(params[:component_id], params[:entity_id])
    @predicate.update_attributes(params[:predicate])
    respond_with @predicate
  end

end
