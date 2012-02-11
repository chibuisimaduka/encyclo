class ComponentsController < ApplicationController

  respond_to :html, :json

  def update
    @component = Component.find(params[:id])
    @component.update_attributes(params[:component])
    respond_with @component
  end

  def create
    @component = Component.new(params[:component])
    if !@component.save
      flash[:notice] = "An error has occured while creating component"
    end
    redirect_to :back
  end

  def destroy
    @component = Component.find(params[:id])
    @component.destroy
    redirect_to @component.entity
  end

end
