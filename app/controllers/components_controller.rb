class ComponentsController < ApplicationController

  def create
    @component = Component.new(params[:component])
    if params["commit"] == "Change parent"
      @entities = Entity.find_all_by_id_or_by_name(params[:associated_entity_id], params[:name], current_language)
      if @entities.size != 1
        redirect_to :back, :alert => 'There must not be ambiguosity to change an entity to a component.'
        return
      else
        @value = @entities.first
        @value.parent_id = params[:component][:entity_id]
        if @value.component_id
          @component = @value.component
          @component.entity_id = @value.parent_id
        end
      end
    else
      if @component.is_entity
        @value = Entity.create({parent_id: params[:component][:entity_id]}, current_user, current_language, params[:name])
      else
        @value = Document.new(entity_ids: [params[:component][:entity_id]], user: current_user, name: params[:name],
          language: current_language, documentable: UserDocument.new)
        @value.user = current_user
      end
    end
    @component.user_id = current_user.id
    @value.component = @component
    #begin
      Component.transaction do
        @value.save!
        @component.save!
        flash[:notice] = 'Component value created succesfully!'
      end
    #rescue
    #  flash[:alert] = "An error has occured while creating component"
    #end
    redirect_to params[:show] ? @value : :back
  end

end
