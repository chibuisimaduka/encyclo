class EntitiesController < ApplicationController

  respond_to :html, :json
  autocomplete :entity, :name
  
  def index
    @entities = Entity.where("parent_id IS NULL")
  end

  def search
    @entity = Entity.find_by_name(params[:search_entity_name])
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
      
      fetch_ranking_elements(@entity)

      if ranking_type == RankingType::USER && !@ranking
        flash[:notice] = "You don't have ranked any entity yet.."
        self.ranking_type = RankingType::TOP
      elsif ranking_type == RankingType::USER
        @entities.delete_if {|e| !@ranking_elements.has_key?(e.id) }
        @entities.sort_by {|e| @ranking_elements[e.id].rating }
      elsif ranking_type == RankingType::SUGGESTED
        @entities.delete_if {|e| @ranking_elements.has_key?(e.id) }
        @entities.sort_by {|e| e.suggested_rating(@ranking_elements) }
      end
    end
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
    if @entity.update_attributes(params[:entity])
      redirect_to(:back, :notice => 'Entity was successfully updated.')
    else
      render :action => "edit"
    end
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
    @entity = Entity.find_or_create_by_name(params[:name])
    @entity.update_attribute :parent_id, params[:parent_id]
    opened_entities[@entity.parent_id] = true
  end

  def random
    redirect_to Entity.offset(rand(Entity.count)).first
  end

private

  def open_entity(entity)
    opened_entities[entity.id] = true
    open_entity(entity.parent) if entity.parent
  end

  def fetch_ranking_elements(entity)
    @ranking = entity.ranking_for current_user
    @ranking_elements = {}
    @ranking.ranking_elements.all.each { |e| @ranking_elements[e.record_id] = e} if @ranking
  end

end
