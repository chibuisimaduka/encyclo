class ImagesController < ApplicationController

  def create
    @entity = Entity.find(params[:entity_id])
    @entity.images.create(params[:image])
    redirect_to @entity
  end

end
