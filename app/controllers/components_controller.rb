class ComponentsController < ApplicationController

  def create
    @component = Component.new(params[:component])
    @component.user_id = current_user.id
    if params["commit"] == "Change parent"
      @entities = Entity.find_all_by_id_or_by_name(params[:component][:associated_entity_id], params[:name], current_language)
      if @entities.size != 1
        redirect_to :back, :notice => 'There must not be ambiguosity to change an entity to a component.'
        return
      else
        @entity = @entities.first
        @entity.parent_id = params[:component][:entity_id]
      end
    else
      @entity = Entity.new(parent_id: params[:component][:entity_id])
      @entity.user_id = current_user.id
      @name = @entity.names.build(language_id: current_language.id)
      @name.set_value(params[:name], current_user)
    end
    @entity.component = @component
    #begin
      Component.transaction do
        @component.save!
        @entity.recalculate_ancestors(true)
        flash[:notice] = 'Entity was succesfully transform into an entity.'
      end
    #rescue
    #  flash[:notice] = "An error has occured while creating component"
    #end
    redirect_to params[:show] ? @entity : :back
  end

end
