class PredicatesController < ApplicationController
  respond_to :html, :json
  
  def update
    @predicate = Predicate.find_or_create_by_component_id_and_entity_id(params[:component_id], params[:entity_id])
    @predicate.add_value(params[:index].to_i, params[:predicate][:"value_#{params[:index]}"])
    @predicate.save
    respond_with @predicate
  end

end
