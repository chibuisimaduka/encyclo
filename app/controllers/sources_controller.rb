class SourcesController < ApplicationController

  def create
    @tag = Tag.find(params[:tag_id])
    @tag.sources.create(params[:source])
    redirect_to @tag
  end

end
