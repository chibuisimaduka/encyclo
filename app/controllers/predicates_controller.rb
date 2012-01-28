class PredicatesController < ApplicationController
  respond_to :html, :json
  
  def update
    @predicate = Predicate.find_or_create_by_component_id_and_entity_id(params[:component_id], params[:entity_id])
    @predicate.add_value(params[:index].to_i, params[:predicate][:value])
    @predicate.update_attribute(:value, @predicate.value) # FIXME: WHY THE FUCK DO I HAVE TO DO THIS?
    @predicate.save!
    respond_with @predicate
  end

end
