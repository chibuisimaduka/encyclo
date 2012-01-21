class TagsController < ApplicationController

  respond_to :html, :json
  autocomplete :tag, :name
  
  def update
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
    respond_with @tag
  end

  def get_autocomplete_items(parameters)
    items = super(parameters)
    params[:tag_id] ? items.joins(:entity).where(:entities => {:tag_id => params[:tag_id]}) : items
  end
end
