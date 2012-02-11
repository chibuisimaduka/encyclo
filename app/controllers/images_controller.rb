class ImagesController < ApplicationController

  def create
    @entity = Entity.find(params[:entity_id])
    @entity.images.create(params[:image].merge(:source => params[:image][:remote_image_url]))
    respond_to do |format|
      format.html { redirect_to @entity }
      format.js
    end
  end

end
