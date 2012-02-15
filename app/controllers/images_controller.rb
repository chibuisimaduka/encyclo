class ImagesController < ApplicationController

  def create
    @entity = Entity.find(params[:entity_id])
    @entity.images.create({:source => params[:image][:remote_image_url], :user_id => current_user.id}.merge(params[:image]))
    respond_to do |format|
      format.html { redirect_to @entity }
      format.js
    end
  end

end
