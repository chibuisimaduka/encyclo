class ComponentsController < ApplicationController

  respond_to :html, :json

  def update
    @component = Component.find(params[:id])
    @component.update_attributes(params[:component])
    respond_with @component
  end

  def create
    @component = Component.new(params[:component])
    @component.save!
    redirect_to :back
  end

end
