class ComponentsController < ApplicationController

  def create
    @component = Component.new(params[:component])
    if params["commit"] == "Change parent"
      @entities = Entity.find_all_by_id_or_by_name(params[:component][:associated_entity_id], params[:name], current_language)
      if @entities.size != 1
        redirect_to :back, :alert => 'There must not be ambiguosity to change an entity to a component.'
        return
      else
        @entity = @entities.first
        @entity.parent_id = params[:component][:entity_id]
        if @entity.component_id
          @component = @entity.component
          @component.entity_id = @entity.parent_id
        end
      end
    else
      @entity = Entity.new(parent_id: params[:component][:entity_id])
      @entity.user_id = current_user.id
      @name = @entity.names.build(language_id: current_language.id)
      @name.set_value(params[:name], current_user)
    end
    @component.user_id = current_user.id
    @entity.component = @component
    begin
      Component.transaction do
        @entity.recalculate_ancestors(true)
        @component.save!
        flash[:notice] = 'Entity was succesfully transform into an entity.'
      end
    rescue
      flash[:alert] = "An error has occured while creating component"
    end
    redirect_to params[:show] ? @entity : :back
  end

end
