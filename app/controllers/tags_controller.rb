class TagsController < ApplicationController

  respond_to :html, :json
  autocomplete :tag, :name
  
  def index
    @tags = params[:search] ? Tag.find(:all, :conditions => ['name LIKE ?', "%#{params[:search]}%"]) : Tag.all(:joins => :entity, :conditions => {:entities => {:tag_id => nil}})
    @tags.delete_if {|t| t.tag == Tag.find_by_name("document") }
  end

  def toggle_on
    opened_tags[params[:tag_name]] = true
	 redirect_to :back
  end

  def toggle_off
    opened_tags.delete params[:tag_name]
	 redirect_to :back
  end

  def create
    @tag = Tag.find_by_name(params[:tag][:name])
    parent_tag_id = params[:tag].delete([:tag_id])
    unless @tag
      @tag = Tag.new(params[:tag])
      @tag.entity = Entity.find_by_name(@tag.name)
      @tag.create_entity!(name: @tag.name) if @tag.entity.blank?
    end

    @tag.entity.tag_id = parent_tag_id
    if @tag.save
      opened_tags[@tag.tag.name] = true if @tag.tag
      redirect_to(:back, :notice => 'Tag was successfully created.')
    else
	   redirect_to(:back, :notice => 'Invalid tag name.')
    end
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
    respond_with @tag
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    redirect_to(tags_url)
  end

  def random
    # FIXME: Don't show all tags ( no empty ones )
    redirect_to entities_path(:tag_name => Tag.offset(rand(Tag.count)).first.name)
  end

  def get_autocomplete_items(parameters)
    super(parameters).where(:tag_id => params[:tag_id])
  end
end
