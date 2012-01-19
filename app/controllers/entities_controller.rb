class EntitiesController < ApplicationController

  autocomplete :entity, :name

  def search
    @entity = Entity.find_by_name(params[:search_entity_name])
    redirect_to @entity
  end

  def show
    @entity = Entity.find(params[:id])#, :include => {:tag => [{:entities => :tags}, {:rankings => :ranking_elements}]})
    # FIXME: fetch_ranking_elements(@entity.tag)

    unless @entity.tag.blank?
      @tag = @entity.tag
	   redirect_to log_in_path if !current_user && ranking_type == RankingType::USER

      # FIXME: Should not be including entities.tags since used for similar tags I think..
      open_tag(@tag)
      @tags_filter = params[:filter] ? params[:filter].collect(&:to_i) : []
      @tags_filter << Tag.find_by_name(params[:new_filter]).id if params[:new_filter]
      @entities = @tag.entities
      @entities.delete_if { |e| (e.tag_ids & @tags_filter).size != @tags_filter.size } unless @tags_filter.blank?
      
      fetch_ranking_elements(@tag)

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
  end

  def tagify
    @entity = Entity.find(params[:id])
    @entity.create_tag!(name: @entity.name)
    redirect_to @entity
  end

  def destroy
    @entity = Entity.find(params[:id])
    @entity.destroy
	 redirect_to :back
  end

  def random
    redirect_to Entity.offset(rand(Entity.count)).first
  end

private

  def open_tag(tag)
    opened_tags[tag.name] = true
    open_tag(tag.tag) if tag.tag && !opened_tags.has_key?(tag.tag.name)
  end

  def fetch_ranking_elements(tag)
    @ranking = tag.ranking_for current_user
    @ranking_elements = {}
    if @ranking
      @ranking.ranking_elements.all.each do |e|
        @ranking_elements[e.record_id] = e
      end
    end
  end

end
