class ImagesController < ApplicationController

  def create
    @entity = Entity.find(params[:entity_id])
    @entity.images.create(params[:image].merge(:source => params[:image][:remote_image_url]))
    redirect_to @entity
  end

end
