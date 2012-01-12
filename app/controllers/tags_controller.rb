class TagsController < ApplicationController
  
  def index
    @tags = Tag.find(:all, :conditions => ['name LIKE ?', "%#{params[:search]}%"])
  end

  def toggle_on
    opened_tags[params[:tag_name]] = true
	 redirect_to :back
  end

  def toggle_off
    opened_tags.delete params[:tag_name]
	 redirect_to :back
  end

  def search
    @tag = Tag.find_by_name(params[:search_tag_name])
    redirect_to entities_path(:tag_name => @tag.name)
  end

  def create
    @tag = Tag.find_by_name(params[:tag][:name])
    if @tag
      @tag.tag_id = params[:tag][:tag_id]
    else
      @tag = Tag.new(params[:tag])
    end

    if @tag.save
      opened_tags[@tag.tag.name] = true if @tag.tag_id
      redirect_to(:back, :notice => 'Tag was successfully created.')
    else
	   redirect_to(:back, :notice => 'Invalid tag name.')
    end
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
end
