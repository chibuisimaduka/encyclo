class SubentitiesController < ApplicationController

  respond_to :html, :json

  def update
    @subentity = Subentity.find(params[:id])
    @subentity.update_attributes(params[:subentity])
    respond_with @subentity
  end

  def create
    @subentity = Subentity.new(params[:subentity])
    @subentity.save!
    redirect_to :back
  end

end
