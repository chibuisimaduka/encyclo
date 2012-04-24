class EntitiesController < ApplicationController

  respond_to :html, :json
  autocomplete :name, :value, :extra_data => ["names.entity_id"]

  def search
    goto_doc = params[:search_entity_name][0] == "=" || params["commit"] != "Search"
    @name = params[:search_entity_name][0] == "=" ? params[:search_entity_name][1..-1].strip : params[:search_entity_name]
    @entities = Entity.find_all_by_id_or_by_name(params[:entity_id], @name, current_language)
    if @entities.size == 1
      redirect_to (goto_doc && !@entities.first.documents.blank?) ? @entities.first.documents.first.link : @entities.first
    elsif @entities.size == 0
      redirect_to :back, :alert => "There is no entity with the name='#{@name}'. Check the spelling or create it."
    else
      render template: "entities/disambiguate"
    end
  end

  require "pretty_printer"
  require "services/adviser/client/entity_adviser_client"

  def show
    @entity = Entity.find(params[:id])

    #unless current_user.is_ip_address?
    #  Entity.joins(:ratings).where("ratings.user_id = #{current_user.id}").limit(Entity.per_page)
    #  params[:offset]
    #end
   
    #top_ranked_entities = Entity.paginate_by_sql(sql, page: params[:page], total_entries: total_entries)

    # FIXME: EntityAdviser should return the number of matching entities.
    @entities = WillPaginate::Collection.create(params[:page] || 1, Entity.per_page, 1000) do |pager|
      pager.replace Entity.find(EntityAdviserClient.get_suggestions(@entity.id, Entity.per_page, 0, []))
    end

    @printer = PrettyPrinter.new(@entity, @entities)
  end

  def edit
    @entity = Entity.find(params[:id])
  end

  def create
    if params["commit"] == "Change parent"
      @entities = Entity.find_all_by_id_or_by_name(params[:entity_id], params[:name], current_language)
      if @entities.size != 1
        redirect_to :back, :alert => 'There must not be ambiguosity to change an entity parent.'
      else
        @entity = @entities.first
        @entity.parent_id = params[:entity][:parent_id]
        begin
          Entity.transaction do
            if @entity.component
              if @entity.component && @entity.component.associated_entity == @entity
                @entity.component.destroy 
              else
                @entity.component_id = nil
              end
            end
            @entity.save!
          end
          redirect_to :back, :notice => 'Entity parent was succesfully changed.'
        rescue
          redirect_to :back, :notice => 'An error has occured while changing the entity parent.'
        end
      end
    else
      @entity = Entity.create(params[:entity], current_user, current_language, params[:name])
      @entity.associations.each {|a| a.user_id = current_user.id }
      if @entity.parent.is_intermediate ? @entity.save : @entity.names.first.save
        flash[:notice] = 'Entity was successfully created.'
      else
        flash[:alert] = 'An error has occured while creating the entity.'
      end
      redirect_to params[:show] ? @entity : :back
    end
  end

  def random
    redirect_to Entity.offset(rand(Entity.count)).first
  end

private

  def get_autocomplete_items(parameters)
    parameters[:term] = parameters[:term][1..-1].strip if parameters[:term][0] == "="
    items = Name.language_scope(super(parameters), current_language)
    # FIXME: Don't show names that the user has edited and don't show names about an entity that the user has deleted.
    params[:parent_id].blank? ? items : (items.joins(:entity).select("entities.parent_id").where("entities.parent_id" => params[:parent_id]) |
      items.joins(:entity => {:associations => :definition}).where("association_definitions.entity_id" => params[:parent_id]) |
      items.joins(:entity => {:associated_associations => :definition}).where("association_definitions.associated_entity_id" => params[:parent_id]))
  end

  def json_for_autocomplete(items, method, extra_data=[])
    all_names = items.map {|e| e.value.downcase }
    items.collect do |n|
      name = (all_names.index(n.value.downcase) != all_names.rindex(n.value.downcase) && !n.entity.parent.blank?) ? n.value + " (#{n.entity.parent.name(current_user, current_language)})" : n.value
      {"id" => n.entity.id.to_s, "label" => name, "value" => name}
    end
  end

end
