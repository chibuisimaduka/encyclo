class EntitiesController < ApplicationController

  respond_to :html, :json
  autocomplete :name, :value, :extra_data => ["names.entity_id"]

  helper_method :destroyable_deleted?

  def index
    @entities = Entity.where("parent_id IS NULL")
  end

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

      open_entity(@entity)
      @entities = @entity.subentities.limit(100) | @entity.entities_by_definition
      @entities.delete_if {|e| destroyable_deleted?(e) }
      params[:filter].each do |definition_id, vals|
        @entities.delete_if {|e| !e.associations.find_by_association_definition_id_and_associated_entity_id(definition_id, vals[:associated_entity_id]) &&
          !e.associated_associations.find_by_association_definition_id_and_entity_id(definition_id, vals[:associated_entity_id])} unless vals[:associated_entity_id].blank?
      end if params[:filter]
      
      if ranking_type == RankingType::USER
        raise "TODO ranking user..."
        @entities.delete_if {|e| !@ranking_elements.has_key?(e.id) }
        @entities.sort_by {|e| @ranking_elements[e.id].rating }
        if @entities.blank?
          flash[:notice] = "You don't have ranked any entity yet.."
          self.ranking_type = RankingType::TOP
        end
      elsif ranking_type == RankingType::SUGGESTED
        raise "TODO ranking suggested..."
        @entities.delete_if {|e| e.has_rating_for(current_user) }
        @entities.sort_by {|e| e.suggested_rating(@entity.entities) }
      end
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
      name_attrs = params[:entity].delete(:names)[0]# There should be a method that creates the associated entity with the hash.
      @entity = Entity.new(params[:entity])
      @entity.user_id = current_user.id
      @entity.names.build(name_attrs)
      @entity.save!
      if params[:show]
        redirect_to @entity
      else
        redirect_to :back, :notice => 'Entity was successfully created.'
      end
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

  def toggle
    @entity = Entity.find(params[:id])

    if opened_entities[@entity.id]
      (@entity.entities + [@entity]).each { |e| opened_entities.delete e.id }
    else
      opened_entities[params[:id].to_i] = true
    end
  end

  def change_parent
    change_entity_parent(Entity.find_or_create_by_name(params[:name]), params[:parent_id])
  end

  def random
    redirect_to Entity.offset(rand(Entity.count)).first
  end

private

  def change_entity_parent(entity, parent_id)
    entity.update_attribute :parent_id, parent_id
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
      name = (all_names.index(n.value.downcase) != all_names.rindex(n.value.downcase) && !n.entity.parent.blank?) ? n.value + " (#{entity_name(n.entity.parent)})" : n.value
      {"id" => n.entity.id.to_s, "label" => name, "value" => name}
    end
  end

  def open_entity(entity)
    opened_entities[entity.id] = true
    open_entity(entity.parent) if entity.parent
  end

  def destroyable_deleted?(destroyable)
    return false unless destroyable.delete_request
    destroyable.delete_request.concurring_users.include?(current_user) || (!destroyable.delete_request.opposing_users.include?(current_user) &&
      (destroyable.delete_request.concurring_users.length - destroyable.delete_request.opposing_users.length) > 3)
  end

end
