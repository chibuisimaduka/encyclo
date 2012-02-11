class EntitiesController < ApplicationController

  respond_to :html, :json
  autocomplete :name, :value, :extra_data => ["names.entity_id"]

  helper_method :destroyable_deleted?

  def search
    goto_doc = params[:search_entity_name][0] == "=" || params["commit"] != "Search"
    name = params[:search_entity_name][0] == "=" ? params[:search_entity_name][1..-1].strip : params[:search_entity_name]
    @entity = params[:entity_id].blank? ? Entity.find_by_name(name) : Entity.find(params[:entity_id])
    redirect_to (goto_doc && !@entity.documents.blank?) ? @entity.documents.first.source : @entity
  end

  require "pretty_printer"

  def show
    @entity = Entity.find(params[:id])

    unless @entity.blank?
	   redirect_to log_in_path if !current_user && ranking_type == RankingType::USER

      # FIXME: Limit 250
      @entities = @entity.entities_by_definition | @entity.subentities_leaves
      @entities.delete_if {|e| destroyable_deleted?(e) }
      params[:filter].each do |definition_id, vals|
        @entities.delete_if {|e| !e.associations.find_by_association_definition_id_and_associated_entity_id(definition_id, vals[:associated_entity_id]) &&
          !e.associated_associations.find_by_association_definition_id_and_entity_id(definition_id, vals[:associated_entity_id])} unless vals[:associated_entity_id].blank?
      end if params[:filter]
      
      @entities = (@entities.sort_by {|e| r = rating_for(e); r ? r.value : e.rank || 0}).reverse
      @entities = @entities.paginate(:page => params[:page])
      #@entities.sort_by {|e| rating_for(e) || e.suggested_rating(@entity.entities) }
    end

    @printer = PrettyPrinter.new(@entity)
  end

  def edit
    @entity = Entity.find(params[:id])
  end

  def create
    if params["commit"] == "Change parent"
      change_entity_parent(Entity.find(params[:entity_id]), params[:entity][:parent_id])
      redirect_to :back, :notice => 'Entity parent was succesfully changed.'
    else
      @entity = Entity.new(params[:entity])
      @entity.user_id = current_user.id
      @name = @entity.names.build(language_id: current_language.id)
      @name.set_value(params[:name], current_user)
      if @entity.save
        flash[:notice] = 'Entity was successfully created.'
      else
        flash[:notice] = 'An error has occured while creating the entity.'
      end
      redirect_to params[:show] ? @entity : :back
    end
  end

  def update
    @entity = Entity.find(params[:id])
    @entity.update_attributes(params[:entity])
    respond_with @entity
  end

  def destroy
    @entity = Entity.find(params[:id])
    @entity.destroy
	 redirect_to @entity.parent ? @entity.parent : root_path
  end

  def change_parent
    change_entity_parent(Entity.find_or_create_by_name(params[:name]), params[:parent_id])
  end

  def random
    redirect_to Entity.offset(rand(Entity.count)).first
  end

private

  def change_entity_parent(entity, parent_id)
    entity.update_attributes(parent_id: parent_id)
    opened_entities[entity.parent_id] = true
  end

  def get_autocomplete_items(parameters)
    parameters[:term] = parameters[:term][1..-1].strip if parameters[:term][0] == "="
    items = super(parameters).where("language_id = ? OR language_id = ?", current_language.id, Language::MAP[:universal].id)
    items.joins(:entity).select("entities.parent_id")
    params[:parent_id].blank? ? items : (items.joins(:entity).where("entities.parent_id" => params[:parent_id]) |
      items.joins(:entity => {:associations => :definition}).where("association_definitions.entity_id" => params[:parent_id]) |
      items.joins(:entity => {:associated_associations => :definition}).where("association_definitions.associated_entity_id" => params[:parent_id]))
  end

  def json_for_autocomplete(items, method, extra_data=[])
    all_names = items.map {|e| e.value.downcase }
    items.collect do |n|
      puts n.id
      name = (all_names.index(n.value.downcase) != all_names.rindex(n.value.downcase) && !n.entity.parent.blank?) ? n.value + " (#{n.entity.parent.name(current_user, current_language)})" : n.value
      {"id" => n.entity.id.to_s, "label" => name, "value" => name}
    end
  end

  def destroyable_deleted?(destroyable)
    return false unless destroyable.delete_request
    destroyable.delete_request.concurring_users.include?(current_user) || (!destroyable.delete_request.opposing_users.include?(current_user) &&
      (destroyable.delete_request.concurring_users.length - destroyable.delete_request.opposing_users.length) > 3)
  end

end
