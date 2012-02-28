class EntitiesController < ApplicationController

  respond_to :html, :json
  autocomplete :name, :value, :extra_data => ["names.entity_id"]

  def search
    goto_doc = params[:search_entity_name][0] == "=" || params["commit"] != "Search"
    @name = params[:search_entity_name][0] == "=" ? params[:search_entity_name][1..-1].strip : params[:search_entity_name]
    @entities = Entity.find_all_by_id_or_by_name(params[:entity_id], @name, current_language)
    if @entities.size == 1
      redirect_to (goto_doc && !@entities.first.documents.blank?) ? @entities.first.documents.first.link : @entities.first
    else
      render template: "entities/disambiguate"
    end
  end

  require "pretty_printer"

  def show
    @entity = Entity.find(params[:id])

    # FIXME: Limit 250
    #@entities = DeleteRequest.alive_scope(Entity.subentity_scope(@entity.descendants), current_user).limit(100)
    @entities = DeleteRequest.alive_scope(Entity.subentity_scope(@entity.entities), current_user).limit(50)
    @entities |= DeleteRequest.alive_scope(Entity.subentity_scope(@entity.direct_entities_by_definition), current_user).limit(50)
    @entities |= DeleteRequest.alive_scope(Entity.subentity_scope(@entity.indirect_entities_by_definition), current_user).limit(50)
    params[:filter].each do |definition_id, vals|
      unless params["refine_#{definition_id}"].blank?
        @entities.delete_if {|e| !e.associations.find_by_association_definition_id_and_associated_entity_id(definition_id, vals[:associated_entity_id]) &&
          !e.associated_associations.find_by_association_definition_id_and_entity_id(definition_id, vals[:associated_entity_id])} unless vals[:associated_entity_id].blank?
      end
    end if params[:filter]
    @entities = (@entities.sort_by {|e| r = Rating.for(e, current_user); r ? r.value : e.rank || 0}).reverse
    @entities = @entities.paginate(:page => params[:page])
    #@entities.sort_by {|e| rating_for(e) || e.suggested_rating(@entity.entities) }

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
        @entity.save
        redirect_to :back, :notice => 'Entity parent was succesfully changed.'
      end
    else
      @entity = Entity.create(params[:entity], current_user, current_language, params[:name])
      if @entity.save
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
    items = super(parameters).where("language_id = ? OR language_id = ?", current_language.id, Language::MAP[:universal].id)
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
