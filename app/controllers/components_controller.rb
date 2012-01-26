class ComponentsController < ApplicationController

  def create
    @component = Component.new(params[:component])
    @component.save!
    redirect_to :back
  end

end
