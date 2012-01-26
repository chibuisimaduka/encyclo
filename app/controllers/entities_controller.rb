class EntitiesController < ApplicationController

  respond_to :html, :json
  autocomplete :name, :value, :extra_data => [:entity_id]
  
  def index
    @entities = Entity.where("parent_id IS NULL")
  end

  def search
    @entity = Entity.find(params[:entity_id])
    redirect_to (params["commit"] == "Search" || @entity.documents.blank?) ? @entity : @entity.documents.first.source
  end

  def show
    @entity = Entity.find(params[:id])

    unless @entity.blank?
	   redirect_to log_in_path if !current_user && ranking_type == RankingType::USER

      open_entity(@entity)
      @tags_filter = params[:filter] ? params[:filter].collect(&:to_i) : []
      @tags_filter << Tag.find_by_name(params[:new_filter]).id if params[:new_filter]
      @entities = @entity.entities
      @entities.delete_if { |e| (e.tag_ids & @tags_filter).size != @tags_filter.size } unless @tags_filter.blank?
      
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
    respond_with @entity
  end

  def edit
    @entity = Entity.find(params[:id])
  end

  def create
    @entity = Entity.new(params[:entity])

    @entity.save!
    #redirect_to(@entity, :notice => 'Entity was successfully created.')
    redirect_to :back, :notice => 'Entity was successfully created.'
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

  def toggle_on
    @entity = Entity.find(params[:id])
    opened_entities[params[:id].to_i] = true
  end

  def toggle_off
    @entity = Entity.find(params[:id])
    (@entity.entities + [@entity]).each do |e|
      opened_entities.delete e.id
    end
  end

  def change_parent
    raise "FIXME: Broken"
    @entity = Entity.find_or_create_by_name(params[:name])
    @entity.update_attribute :parent_id, params[:parent_id]
    opened_entities[@entity.parent_id] = true
  end

  def random
    redirect_to Entity.offset(rand(Entity.count)).first
  end

private

  def json_for_autocomplete(items, method, extra_data=[])
    items.find_all_by_language_id(current_language.id).map do |n|
      name = (items.find_all_by_value(n.value).size > 1) ? n.value + " (#{n.entity.parent.name(current_language)})" : n.value
      {"id" => n.entity.id.to_s, "label" => name, "value" => name}
    end
  end

  def open_entity(entity)
    opened_entities[entity.id] = true
    open_entity(entity.parent) if entity.parent
  end

end
