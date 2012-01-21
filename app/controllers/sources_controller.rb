class SourcesController < ApplicationController

  def create
    @entity = Tag.find(params[:entity_id])
    @entity.sources.create(params[:source])
    redirect_to @entity
  end

end
