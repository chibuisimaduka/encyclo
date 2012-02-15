class ImagesController < ApplicationController

  def create
    @entity = Entity.find(params[:entity_id])
    if !@entity.images.create({:source => params[:image][:remote_image_url], :user_id => current_user.id}.merge(params[:image]))
      flash[:notice] = "An error has occured while creating the images."
    end
    respond_to do |format|
      format.html { redirect_to @entity }
      format.js
    end
  end

end
