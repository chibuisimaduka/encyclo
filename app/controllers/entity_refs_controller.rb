class EntityRefsController < ApplicationController
  respond_to :html, :json
  
  def update
    @predicate = Predicate.find_or_create_by_component_id_and_entity_id(params[:component_id], params[:entity_id])
    raise "Trying to set more than one entity_ref for a component which only takes one." if !params[:entity_ref] && @predicate.entity_refs.size > 0 && !@predicate.component.is_many
    @entity_ref = params[:entity_ref_id] ? @predicate.entity_refs.find(params[:entity_ref_id]) : @predicate.entity_refs.build
    @entity_ref.name = params[:entity_ref][:name]
    @entity_ref.entity = Entity.find_by_name(@entity_ref.name)
    @predicate.save if @entity_ref.save
    respond_with @entity_ref
  end

end
