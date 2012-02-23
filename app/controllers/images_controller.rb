class ImagesController < ApplicationController

  def index
    @entity = Entity.find(params[:entity_id])
  end

  def create
    @entity = Entity.find(params[:entity_id])
    @image = @entity.images.build(params[:image])
    @image.user_id = current_user.id
    @image.source = params[:image][:remote_image_url]
    if !@entity.save
      flash[:alert] = "An error has occured while creating the images."
    end
    respond_to do |format|
      format.html { redirect_to @entity }
      format.js
    end
  end

end
